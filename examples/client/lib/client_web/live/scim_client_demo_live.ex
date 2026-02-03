defmodule ClientWeb.ScimClientDemoLive do
  use ClientWeb, :live_view

  alias ExScimClient.Client, as: ScimClient
  alias ExScimClient.Resources.ServiceProviderConfig
  alias Client.ScimTesting

  @capability_display_items [
    {"patch", "PATCH Operations"},
    {"bulk", "Bulk Operations"},
    {"filter", "Filtering"},
    {"changePassword", "Change Password"},
    {"sort", "Sorting"},
    {"etag", "ETags"}
  ]

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        base_url: "",
        bearer_token: "",
        client: nil,
        test_results: ScimTesting.init_test_results(),
        current_test: nil,
        running: false,
        test_task_pid: nil,
        progress: 0,
        logs: [],
        created_user_id: nil,
        enabled_tests: ScimTesting.default_enabled_tests(),
        capabilities: nil,
        capabilities_applied: false,
        modal_output: nil
      )

    send(self(), :load_saved_config)

    {:ok, socket}
  end

  def handle_event(
        "update_config",
        %{"base_url" => base_url, "bearer_token" => bearer_token},
        socket
      ) do
    {normalized_base_url, client} = create_scim_client(base_url, bearer_token)

    socket =
      socket
      |> assign(
        base_url: normalized_base_url,
        bearer_token: bearer_token,
        client: client
      )
      |> maybe_fetch_capabilities(client)

    {:noreply, socket}
  end

  def handle_event("start_tests", _params, socket) do
    case validate_configuration(socket) do
      :ok ->
        send(self(), :run_tests)

        socket =
          assign(socket,
            running: true,
            progress: 0,
            test_results: ScimTesting.init_test_results(),
            logs: [],
            created_user_id: nil
          )

        {:noreply, socket}

      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("stop_tests", _params, socket) do
    if socket.assigns.test_task_pid do
      Process.exit(socket.assigns.test_task_pid, :kill)
    end

    test_results =
      socket.assigns.test_results
      |> Enum.map(fn {test_id, result} ->
        if result.status == :running do
          {test_id, %{status: :pending, result: nil, error: nil}}
        else
          {test_id, result}
        end
      end)
      |> Map.new()

    socket =
      assign(socket,
        running: false,
        current_test: nil,
        test_task_pid: nil,
        test_results: test_results,
        progress: 0
      )

    {:noreply, put_flash(socket, :info, "Tests stopped")}
  end

  def handle_event("retry_test", %{"test_id" => test_id}, socket) do
    test_atom = String.to_existing_atom(test_id)
    send(self(), {:retry_test, test_atom})

    socket =
      update(socket, :test_results, fn results ->
        Map.put(results, test_atom, %{status: :running, result: nil, error: nil})
      end)

    {:noreply, socket}
  end

  def handle_event(
        "config_loaded",
        %{"base_url" => base_url, "bearer_token" => bearer_token},
        socket
      ) do
    {normalized_base_url, client} = create_scim_client(base_url, bearer_token)

    socket =
      socket
      |> assign(
        base_url: normalized_base_url,
        bearer_token: bearer_token,
        client: client
      )
      |> maybe_fetch_capabilities(client)

    {:noreply, socket}
  end

  def handle_event("refresh_capabilities", _params, socket) do
    socket =
      socket
      |> assign(capabilities_applied: false)
      |> maybe_fetch_capabilities(socket.assigns.client)

    {:noreply, socket}
  end

  def handle_event("toggle_test", %{"test-id" => test_id}, socket) do
    test_atom = String.to_existing_atom(test_id)
    enabled_tests = socket.assigns.enabled_tests

    enabled_tests =
      if MapSet.member?(enabled_tests, test_atom) do
        # Disabling: also disable all dependents
        dependents = ScimTesting.dependents_of(test_atom)
        to_disable = MapSet.new([test_atom | dependents])
        MapSet.difference(enabled_tests, to_disable)
      else
        # Enabling: also enable all dependencies
        dependencies = ScimTesting.dependencies_of(test_atom)
        to_enable = MapSet.new([test_atom | dependencies])
        MapSet.union(enabled_tests, to_enable)
      end

    {:noreply, assign(socket, enabled_tests: enabled_tests)}
  end

  def handle_event("toggle_all_tests", %{"action" => "enable"}, socket) do
    {:noreply, assign(socket, enabled_tests: ScimTesting.default_enabled_tests())}
  end

  def handle_event("toggle_all_tests", %{"action" => "disable"}, socket) do
    {:noreply, assign(socket, enabled_tests: MapSet.new())}
  end

  def handle_event("show_full_output", %{"test_id" => test_id, "type" => type}, socket) do
    test_atom = String.to_existing_atom(test_id)
    test_result = Map.get(socket.assigns.test_results, test_atom)
    test_def = Enum.find(ScimTesting.test_definitions(), &(&1.id == test_atom))

    content =
      case type do
        "error" -> inspect(test_result.error, pretty: true, limit: :infinity, width: 80)
        "result" -> inspect(test_result.result, pretty: true, limit: :infinity, width: 80)
      end

    modal_output = %{
      test_id: test_atom,
      test_name: test_def.name,
      type: type,
      content: content
    }

    {:noreply, assign(socket, modal_output: modal_output)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, modal_output: nil)}
  end

  def handle_info(:run_tests, socket) do
    live_view_pid = self()
    enabled_tests = socket.assigns.enabled_tests

    {:ok, task_pid} =
      Task.start(fn ->
        ScimTesting.run_all_tests(live_view_pid, socket.assigns.client, enabled_tests)
      end)

    socket = assign(socket, test_task_pid: task_pid)
    {:noreply, socket}
  end

  def handle_info({:retry_test, test_id}, socket) do
    live_view_pid = self()

    Task.start(fn ->
      ScimTesting.run_single_test(
        live_view_pid,
        socket.assigns.client,
        test_id,
        socket.assigns.created_user_id
      )
    end)

    {:noreply, socket}
  end

  def handle_info({:test_started, test_id}, socket) do
    socket = assign(socket, current_test: test_id)

    socket =
      update(socket, :test_results, fn results ->
        Map.put(results, test_id, %{status: :running, result: nil, error: nil})
      end)

    {:noreply, socket}
  end

  def handle_info({:test_completed, test_id, result}, socket) do
    socket =
      update(socket, :test_results, fn results ->
        Map.put(results, test_id, %{status: :success, result: result, error: nil})
      end)

    socket =
      update(socket, :progress, fn progress ->
        min(progress + 10, 100)
      end)

    {:noreply, socket}
  end

  def handle_info({:test_failed, test_id, error}, socket) do
    socket =
      update(socket, :test_results, fn results ->
        Map.put(results, test_id, %{status: :error, result: nil, error: error})
      end)

    socket =
      update(socket, :progress, fn progress ->
        min(progress + 10, 100)
      end)

    {:noreply, socket}
  end

  def handle_info({:user_created, user_id}, socket) do
    {:noreply, assign(socket, created_user_id: user_id)}
  end

  def handle_info({:log_message, message}, socket) do
    socket =
      update(socket, :logs, fn logs ->
        [%{timestamp: DateTime.utc_now(), message: message} | logs]
      end)

    {:noreply, socket}
  end

  def handle_info({:tests_completed}, socket) do
    socket =
      assign(socket,
        running: false,
        current_test: nil,
        progress: 100,
        test_task_pid: nil
      )

    {:noreply, socket}
  end

  def handle_info(:load_saved_config, socket) do
    {:noreply, push_event(socket, "load_saved_config", %{})}
  end

  def handle_info({:capabilities_fetched, {:ok, body}}, socket) do
    socket = assign(socket, capabilities: {:ok, body})

    socket =
      if socket.assigns.capabilities_applied do
        socket
      else
        enabled = ScimTesting.enabled_tests_for_capabilities(body)
        assign(socket, enabled_tests: enabled, capabilities_applied: true)
      end

    {:noreply, socket}
  end

  def handle_info({:capabilities_fetched, {:error, reason}}, socket) do
    message =
      case reason do
        msg when is_binary(msg) -> msg
        other -> inspect(other)
      end

    {:noreply, assign(socket, capabilities: {:error, message})}
  end

  def test_definitions, do: ScimTesting.test_definitions()

  def capability_supported?(capabilities, key) do
    case capabilities do
      {:ok, body} -> get_in(body, [key, "supported"]) == true
      _ -> nil
    end
  end

  def capabilities_summary(capabilities) do
    Enum.map(@capability_display_items, fn {key, label} ->
      {label, capability_supported?(capabilities, key)}
    end)
  end

  def auth_schemes(capabilities) do
    case capabilities do
      {:ok, body} -> Map.get(body, "authenticationSchemes", [])
      _ -> []
    end
  end

  def test_unsupported_by_provider?(capabilities, test_id) do
    case capabilities do
      {:ok, body} ->
        disabled = ScimTesting.tests_disabled_by_capabilities(body)
        test_id in disabled

      _ ->
        false
    end
  end

  defp maybe_fetch_capabilities(socket, nil) do
    assign(socket, capabilities: nil)
  end

  defp maybe_fetch_capabilities(socket, client) do
    live_view_pid = self()

    Task.start(fn ->
      result =
        try do
          ServiceProviderConfig.get(client)
        rescue
          error -> {:error, "Connection failed: #{inspect(error)}"}
        catch
          :exit, reason -> {:error, "Connection terminated: #{inspect(reason)}"}
        end

      send(live_view_pid, {:capabilities_fetched, result})
    end)

    assign(socket, capabilities: :loading)
  end

  defp create_scim_client("", _bearer_token), do: {"", nil}
  defp create_scim_client(_base_url, ""), do: {"", nil}

  defp create_scim_client(base_url, bearer_token) do
    normalized_base_url = normalize_base_url(base_url)
    client = ScimClient.new(normalized_base_url, bearer_token)
    {normalized_base_url, client}
  end

  defp normalize_base_url(base_url) do
    base_url = String.trim_trailing(base_url, "/")

    if String.ends_with?(base_url, "/scim/v2") do
      base_url
    else
      base_url <> "/scim/v2"
    end
  end

  defp validate_configuration(socket) do
    cond do
      MapSet.size(socket.assigns.enabled_tests) == 0 ->
        {:error, "Please select at least one test to run"}

      socket.assigns.base_url == "" ->
        {:error, "Please configure a valid BASE_URL (e.g., https://your-scim-server.com)"}

      socket.assigns.bearer_token == "" ->
        {:error, "Please configure a valid BEARER_TOKEN"}

      socket.assigns.client == nil ->
        {:error, "SCIM client configuration failed"}

      true ->
        :ok
    end
  end

  @max_output_length 500

  def truncate_output(data) do
    output = inspect(data, pretty: true, limit: 50, width: 60)

    if String.length(output) > @max_output_length do
      String.slice(output, 0, @max_output_length) <> "\n..."
    else
      output
    end
  end
end

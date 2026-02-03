defmodule ExScimPhoenix.Controller.ServiceProviderConfigControllerTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import ExScimPhoenix.Test.ConnHelpers

  alias ExScimPhoenix.Controller.ServiceProviderConfigController

  @config_keys [
    :patch_supported,
    :bulk_supported,
    :bulk_max_operations,
    :bulk_max_payload_size,
    :filter_supported,
    :filter_max_results,
    :change_password_supported,
    :sort_supported,
    :etag_supported,
    :documentation_uri,
    :authentication_schemes
  ]

  describe "show/2 with default config" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "returns correct SCIM schema" do
      response = call_show() |> decode_response()

      assert response["schemas"] == [
               "urn:ietf:params:scim:schemas:core:2.0:ServiceProviderConfig"
             ]
    end

    test "patch defaults to not supported" do
      response = call_show() |> decode_response()
      assert response["patch"] == %{"supported" => false}
    end

    test "bulk defaults to supported with default limits" do
      response = call_show() |> decode_response()
      assert response["bulk"]["supported"] == true
      assert response["bulk"]["maxOperations"] == 1000
      assert response["bulk"]["maxPayloadSize"] == 1_048_576
    end

    test "filter defaults to not supported without maxResults" do
      response = call_show() |> decode_response()
      assert response["filter"] == %{"supported" => false}
      refute Map.has_key?(response["filter"], "maxResults")
    end

    test "changePassword defaults to not supported" do
      response = call_show() |> decode_response()
      assert response["changePassword"] == %{"supported" => false}
    end

    test "sort defaults to not supported" do
      response = call_show() |> decode_response()
      assert response["sort"] == %{"supported" => false}
    end

    test "etag defaults to not supported" do
      response = call_show() |> decode_response()
      assert response["etag"] == %{"supported" => false}
    end

    test "documentationUri is absent by default" do
      response = call_show() |> decode_response()
      refute Map.has_key?(response, "documentationUri")
    end

    test "authenticationSchemes defaults to empty list" do
      response = call_show() |> decode_response()
      assert response["authenticationSchemes"] == []
    end
  end

  describe "show/2 with capabilities enabled" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "patch supported when configured" do
      Application.put_env(:ex_scim, :patch_supported, true)
      response = call_show() |> decode_response()
      assert response["patch"]["supported"] == true
    end

    test "changePassword supported when configured" do
      Application.put_env(:ex_scim, :change_password_supported, true)
      response = call_show() |> decode_response()
      assert response["changePassword"]["supported"] == true
    end

    test "sort supported when configured" do
      Application.put_env(:ex_scim, :sort_supported, true)
      response = call_show() |> decode_response()
      assert response["sort"]["supported"] == true
    end

    test "etag supported when configured" do
      Application.put_env(:ex_scim, :etag_supported, true)
      response = call_show() |> decode_response()
      assert response["etag"]["supported"] == true
    end
  end

  describe "show/2 documentationUri" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "included when configured" do
      Application.put_env(:ex_scim, :documentation_uri, "https://example.com/docs")
      response = call_show() |> decode_response()
      assert response["documentationUri"] == "https://example.com/docs"
    end

    test "absent when nil" do
      Application.put_env(:ex_scim, :documentation_uri, nil)
      response = call_show() |> decode_response()
      refute Map.has_key?(response, "documentationUri")
    end
  end

  describe "show/2 authenticationSchemes" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "returns configured schemes" do
      schemes = [
        %{
          "type" => "oauthbearertoken",
          "name" => "OAuth Bearer Token",
          "description" => "Authentication scheme using the OAuth Bearer Token Standard",
          "specUri" => "https://www.rfc-editor.org/info/rfc6750",
          "primary" => true
        },
        %{
          "type" => "httpbasic",
          "name" => "HTTP Basic",
          "description" => "Authentication scheme using the HTTP Basic Standard"
        }
      ]

      Application.put_env(:ex_scim, :authentication_schemes, schemes)
      response = call_show() |> decode_response()

      assert length(response["authenticationSchemes"]) == 2

      oauth = Enum.find(response["authenticationSchemes"], &(&1["type"] == "oauthbearertoken"))
      assert oauth["name"] == "OAuth Bearer Token"
      assert oauth["primary"] == true

      basic = Enum.find(response["authenticationSchemes"], &(&1["type"] == "httpbasic"))
      assert basic["name"] == "HTTP Basic"
      refute Map.has_key?(basic, "primary")
    end
  end

  describe "show/2 bulk sub-fields" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "includes maxOperations and maxPayloadSize when bulk supported" do
      Application.put_env(:ex_scim, :bulk_supported, true)
      Application.put_env(:ex_scim, :bulk_max_operations, 500)
      Application.put_env(:ex_scim, :bulk_max_payload_size, 2_000_000)

      response = call_show() |> decode_response()
      assert response["bulk"]["supported"] == true
      assert response["bulk"]["maxOperations"] == 500
      assert response["bulk"]["maxPayloadSize"] == 2_000_000
    end

    test "omits maxOperations and maxPayloadSize when bulk not supported" do
      Application.put_env(:ex_scim, :bulk_supported, false)

      response = call_show() |> decode_response()
      assert response["bulk"] == %{"supported" => false}
      refute Map.has_key?(response["bulk"], "maxOperations")
      refute Map.has_key?(response["bulk"], "maxPayloadSize")
    end
  end

  describe "show/2 filter sub-fields" do
    setup do
      saved = save_config()
      clear_config()
      on_exit(fn -> restore_config(saved) end)
      :ok
    end

    test "includes maxResults when filter supported" do
      Application.put_env(:ex_scim, :filter_supported, true)
      Application.put_env(:ex_scim, :filter_max_results, 500)

      response = call_show() |> decode_response()
      assert response["filter"]["supported"] == true
      assert response["filter"]["maxResults"] == 500
    end

    test "uses default maxResults of 200 when filter supported" do
      Application.put_env(:ex_scim, :filter_supported, true)

      response = call_show() |> decode_response()
      assert response["filter"]["maxResults"] == 200
    end

    test "omits maxResults when filter not supported" do
      Application.put_env(:ex_scim, :filter_supported, false)

      response = call_show() |> decode_response()
      assert response["filter"] == %{"supported" => false}
      refute Map.has_key?(response["filter"], "maxResults")
    end
  end

  defp save_config do
    Enum.map(@config_keys, fn key ->
      {key, Application.get_env(:ex_scim, key)}
    end)
  end

  defp restore_config(saved) do
    Enum.each(saved, fn {key, value} ->
      if value == nil do
        Application.delete_env(:ex_scim, key)
      else
        Application.put_env(:ex_scim, key, value)
      end
    end)
  end

  defp clear_config do
    Enum.each(@config_keys, fn key ->
      Application.delete_env(:ex_scim, key)
    end)
  end

  defp call_show do
    conn = conn(:get, "/ServiceProviderConfig")
    ServiceProviderConfigController.show(conn, %{})
  end
end

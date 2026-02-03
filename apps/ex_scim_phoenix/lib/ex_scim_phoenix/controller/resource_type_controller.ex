defmodule ExScimPhoenix.Controller.ResourceTypeController do
  use Phoenix.Controller, formats: [:json]

  alias ExScim.Schema.Repository

  @moduledoc """
  SCIM v2.0 ResourceType endpoint implementation (RFC 7644 Section 4)
  Provides metadata about the resource types supported by the service provider.
  """

  def index(conn, _params) do
    resource_types = build_resource_types()

    response = %{
      "schemas" => ["urn:ietf:params:scim:api:messages:2.0:ListResponse"],
      "totalResults" => length(resource_types),
      "startIndex" => 1,
      "itemsPerPage" => length(resource_types),
      "Resources" => resource_types
    }

    conn
    |> put_resp_content_type("application/scim+json")
    |> json(response)
  end

  def show(conn, %{"id" => id}) do
    resource_types = build_resource_types()

    case find_resource_type(resource_types, id) do
      nil ->
        error_response = %{
          "schemas" => ["urn:ietf:params:scim:api:messages:2.0:Error"],
          "detail" => "Resource #{id} not found",
          "status" => "404"
        }

        conn
        |> put_status(:not_found)
        |> put_resp_content_type("application/scim+json")
        |> json(error_response)

      resource_type ->
        conn
        |> put_resp_content_type("application/scim+json")
        |> json(resource_type)
    end
  end

  # Build resource types dynamically using Schema Repository
  defp build_resource_types do
    base_url = ExScim.Config.base_url()
    schemas = Repository.list_schemas()
    
    # Define resource type mappings based on available schemas
    resource_type_mappings = %{
      "urn:ietf:params:scim:schemas:core:2.0:User" => %{
        "id" => "User",
        "name" => "User", 
        "endpoint" => "/Users",
        "description" => "User Account"
      },
      "urn:ietf:params:scim:schemas:core:2.0:Group" => %{
        "id" => "Group",
        "name" => "Group",
        "endpoint" => "/Groups", 
        "description" => "Group Account"
      }
    }

    # Build resource types for core schemas only (not extensions)
    core_schemas = Enum.filter(schemas, fn schema ->
      schema_id = schema["id"]
      Map.has_key?(resource_type_mappings, schema_id) and 
      not String.contains?(schema_id, "extension")
    end)

    Enum.map(core_schemas, fn schema ->
      schema_id = schema["id"] 
      mapping = resource_type_mappings[schema_id]
      
      resource_type = %{
        "schemas" => ["urn:ietf:params:scim:schemas:core:2.0:ResourceType"],
        "id" => mapping["id"],
        "name" => mapping["name"],
        "endpoint" => mapping["endpoint"], 
        "description" => mapping["description"],
        "schema" => schema_id,
        "meta" => %{
          "location" => "#{base_url}/scim/v2/ResourceTypes/#{mapping["id"]}",
          "resourceType" => "ResourceType"
        }
      }

      # Add schema extensions for User resource type
      if mapping["id"] == "User" do
        enterprise_extension = "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"
        if Repository.has_schema?(enterprise_extension) do
          Map.put(resource_type, "schemaExtensions", [
            %{
              "schema" => enterprise_extension,
              "required" => false
            }
          ])
        else
          resource_type
        end
      else
        resource_type
      end
    end)
  end

  defp find_resource_type(resource_types, id) do
    Enum.find(resource_types, fn rt -> rt["id"] == id end)
  end
end

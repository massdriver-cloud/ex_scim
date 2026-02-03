defmodule ExScimPhoenix.Controller.ResourceTypeControllerTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import Plug.Conn
  import ExScimPhoenix.Test.ConnHelpers

  alias ExScimPhoenix.Controller.ResourceTypeController

  describe "index/2" do
    test "returns list of resource types with correct SCIM ListResponse format" do
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.index(conn, %{})

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/scim+json; charset=utf-8"]

      response = decode_response(conn)

      # Verify SCIM ListResponse schema
      assert response["schemas"] == ["urn:ietf:params:scim:api:messages:2.0:ListResponse"]
      assert response["totalResults"] == 2
      assert response["startIndex"] == 1
      assert response["itemsPerPage"] == 2
      assert is_list(response["Resources"])
      assert length(response["Resources"]) == 2
    end

    test "returns User and Group resource types" do
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.index(conn, %{})

      response = decode_response(conn)
      resource_types = response["Resources"]

      user_rt = Enum.find(resource_types, fn rt -> rt["id"] == "User" end)
      group_rt = Enum.find(resource_types, fn rt -> rt["id"] == "Group" end)

      refute is_nil(user_rt)
      refute is_nil(group_rt)
    end

    test "User resource type has correct attributes" do
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.index(conn, %{})

      response = decode_response(conn)
      user_rt = Enum.find(response["Resources"], fn rt -> rt["id"] == "User" end)

      # Verify required RFC 7643 attributes
      assert user_rt["schemas"] == ["urn:ietf:params:scim:schemas:core:2.0:ResourceType"]
      assert user_rt["id"] == "User"
      assert user_rt["name"] == "User"
      assert user_rt["endpoint"] == "/Users"
      assert user_rt["description"] == "User Account"
      assert user_rt["schema"] == "urn:ietf:params:scim:schemas:core:2.0:User"

      # Verify schemaExtensions
      assert is_list(user_rt["schemaExtensions"])
      assert length(user_rt["schemaExtensions"]) == 1

      enterprise_ext = List.first(user_rt["schemaExtensions"])
      assert enterprise_ext["schema"] == "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"
      assert enterprise_ext["required"] == false

      # Verify meta object
      assert is_map(user_rt["meta"])
      assert user_rt["meta"]["resourceType"] == "ResourceType"
      assert String.contains?(user_rt["meta"]["location"], "/scim/v2/ResourceTypes/User")
    end

    test "Group resource type has correct attributes" do
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.index(conn, %{})

      response = decode_response(conn)
      group_rt = Enum.find(response["Resources"], fn rt -> rt["id"] == "Group" end)

      # Verify required RFC 7643 attributes
      assert group_rt["schemas"] == ["urn:ietf:params:scim:schemas:core:2.0:ResourceType"]
      assert group_rt["id"] == "Group"
      assert group_rt["name"] == "Group"
      assert group_rt["endpoint"] == "/Groups"
      assert group_rt["description"] == "Group Account"
      assert group_rt["schema"] == "urn:ietf:params:scim:schemas:core:2.0:Group"

      # Verify meta object
      assert is_map(group_rt["meta"])
      assert group_rt["meta"]["resourceType"] == "ResourceType"
      assert String.contains?(group_rt["meta"]["location"], "/scim/v2/ResourceTypes/Group")
    end
  end

  describe "show/2" do
    test "returns specific User resource type" do
      conn = conn(:get, "/ResourceTypes/User")
      conn = ResourceTypeController.show(conn, %{"id" => "User"})

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/scim+json; charset=utf-8"]

      response = decode_response(conn)

      assert response["schemas"] == ["urn:ietf:params:scim:schemas:core:2.0:ResourceType"]
      assert response["id"] == "User"
      assert response["name"] == "User"
      assert response["endpoint"] == "/Users"
      assert response["schema"] == "urn:ietf:params:scim:schemas:core:2.0:User"
    end

    test "returns specific Group resource type" do
      conn = conn(:get, "/ResourceTypes/Group")
      conn = ResourceTypeController.show(conn, %{"id" => "Group"})

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/scim+json; charset=utf-8"]

      response = decode_response(conn)

      assert response["schemas"] == ["urn:ietf:params:scim:schemas:core:2.0:ResourceType"]
      assert response["id"] == "Group"
      assert response["name"] == "Group"
      assert response["endpoint"] == "/Groups"
      assert response["schema"] == "urn:ietf:params:scim:schemas:core:2.0:Group"
    end

    test "returns 404 for non-existent resource type" do
      conn = conn(:get, "/ResourceTypes/NonExistent")
      conn = ResourceTypeController.show(conn, %{"id" => "NonExistent"})

      assert conn.status == 404
      assert get_resp_header(conn, "content-type") == ["application/scim+json; charset=utf-8"]

      response = decode_response(conn)

      assert response["schemas"] == ["urn:ietf:params:scim:api:messages:2.0:Error"]
      assert response["detail"] == "Resource NonExistent not found"
      assert response["status"] == "404"
    end

    test "handles case-sensitive resource type IDs" do
      # Test lowercase - should not match
      conn = conn(:get, "/ResourceTypes/user")
      conn = ResourceTypeController.show(conn, %{"id" => "user"})

      assert conn.status == 404

      # Test correct case - should match
      conn = conn(:get, "/ResourceTypes/User")
      conn = ResourceTypeController.show(conn, %{"id" => "User"})

      assert conn.status == 200
    end
  end

  describe "configuration integration" do
    test "uses base_url from ExScim.Config in meta.location" do
      # Mock the config (this would typically be done with a mocking library)
      original_base_url = Application.get_env(:ex_scim, :base_url, "http://localhost:4000")

      try do
        Application.put_env(:ex_scim, :base_url, "https://example.com")

        conn = conn(:get, "/ResourceTypes/User")
        conn = ResourceTypeController.show(conn, %{"id" => "User"})

        response = decode_response(conn)
        assert response["meta"]["location"] == "https://example.com/scim/v2/ResourceTypes/User"
      after
        # Restore original config
        if original_base_url do
          Application.put_env(:ex_scim, :base_url, original_base_url)
        else
          Application.delete_env(:ex_scim, :base_url)
        end
      end
    end
  end

  describe "Schema Repository integration" do
    test "uses Schema.Repository to determine available schemas" do
      # Verify that the controller gets schemas from the repository
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.show(conn, %{"id" => "User"})

      assert conn.status == 200
      response = decode_response(conn)
      
      # The User schema should be referenced
      assert response["schema"] == "urn:ietf:params:scim:schemas:core:2.0:User"
      
      # Schema extensions should be included if available in repository
      enterprise_extension = "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"
      if ExScim.Schema.Repository.has_schema?(enterprise_extension) do
        assert is_list(response["schemaExtensions"])
        extension = Enum.find(response["schemaExtensions"], fn ext -> 
          ext["schema"] == enterprise_extension
        end)
        refute is_nil(extension)
        assert extension["required"] == false
      end
    end

    test "only includes resource types for schemas that exist in repository" do
      conn = conn(:get, "/ResourceTypes")
      conn = ResourceTypeController.index(conn, %{})

      response = decode_response(conn)
      resource_types = response["Resources"]
      
      # Each resource type should correspond to an existing schema
      Enum.each(resource_types, fn rt ->
        schema_uri = rt["schema"]
        assert ExScim.Schema.Repository.has_schema?(schema_uri)
      end)
    end
  end
end
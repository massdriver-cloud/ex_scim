defmodule ExScimPhoenix.Router do
  @moduledoc """
  Router macro for adding SCIM 2.0 HTTP endpoints to Phoenix applications.
  
  Provides a complete set of SCIM 2.0 compliant routes including Users, Groups,
  search, bulk operations, and discovery endpoints.
  
  ## Usage
  
      defmodule MyAppWeb.Router do
        use Phoenix.Router
        use ExScimPhoenix.Router
        
        scope "/scim/v2" do
          pipe_through [:api, :scim_auth]
          scim_routes()
        end
      end
  
  ## Custom Controllers
  
  Override default controllers by passing options:
  
      use ExScimPhoenix.Router,
        user_controller: MyApp.CustomUserController,
        group_controller: MyApp.CustomGroupController
  
  ## Available Routes
  
  - `GET /Users` - List users
  - `POST /Users` - Create user  
  - `GET /Users/:id` - Get user
  - `PUT /Users/:id` - Replace user
  - `PATCH /Users/:id` - Update user
  - `DELETE /Users/:id` - Delete user
  - Similar routes for `/Groups` and `/Me`
  - `GET /ServiceProviderConfig` - Server capabilities
  - `GET /ResourceTypes` - Available resource types
  - `GET /Schemas` - Resource schemas
  - `POST /.search` - Cross-resource search
  - `POST /Bulk` - Bulk operations
  """
  
  defmacro __using__(opts) do
    user_controller =
      Keyword.get(opts, :user_controller, ExScimPhoenix.Controller.UserController)

    me_controller = Keyword.get(opts, :me_controller, ExScimPhoenix.Controller.MeController)

    group_controller =
      Keyword.get(opts, :group_controller, ExScimPhoenix.Controller.GroupController)

    service_provider_config_controller =
      Keyword.get(
        opts,
        :service_provider_config_controller,
        ExScimPhoenix.Controller.ServiceProviderConfigController
      )

    resource_type_controller =
      Keyword.get(
        opts,
        :resource_type_controller,
        ExScimPhoenix.Controller.ResourceTypeController
      )

    schema_controller =
      Keyword.get(opts, :schema_controller, ExScimPhoenix.Controller.SchemaController)

    search_controller =
      Keyword.get(opts, :search_controller, ExScimPhoenix.Controller.SearchController)

    bulk_controller =
      Keyword.get(opts, :bulk_controller, ExScimPhoenix.Controller.BulkController)

    quote do
      # SCIM v2 API routes - RFC 7644 compliant

      # User resource endpoints - RFC 7644
      get("/Users", unquote(user_controller), :index)
      post("/Users", unquote(user_controller), :create)
      get("/Users/:id", unquote(user_controller), :show)
      put("/Users/:id", unquote(user_controller), :update)
      patch("/Users/:id", unquote(user_controller), :patch)
      delete("/Users/:id", unquote(user_controller), :delete)

      # Me endpoint - RFC 7644
      get("/Me", unquote(me_controller), :show)
      post("/Me", unquote(me_controller), :create)
      put("/Me", unquote(me_controller), :update)
      patch("/Me", unquote(me_controller), :patch)
      delete("/Me", unquote(me_controller), :delete)

      # Group resource endpoints - RFC 7644
      get("/Groups", unquote(group_controller), :index)
      post("/Groups", unquote(group_controller), :create)
      get("/Groups/:id", unquote(group_controller), :show)
      put("/Groups/:id", unquote(group_controller), :update)
      patch("/Groups/:id", unquote(group_controller), :patch)
      delete("/Groups/:id", unquote(group_controller), :delete)

      # Service Provider Configuration - RFC 7643
      get("/ServiceProviderConfig", unquote(service_provider_config_controller), :show)

      # Resource Type definitions - RFC 7643
      get("/ResourceTypes", unquote(resource_type_controller), :index)
      get("/ResourceTypes/:id", unquote(resource_type_controller), :show)

      # Schema definitions - RFC 7643
      get("/Schemas", unquote(schema_controller), :index)
      get("/Schemas/:id", unquote(schema_controller), :show)

      # Search endpoints - RFC 7644
      post("/Users/.search", unquote(search_controller), :search)
      post("/Groups/.search", unquote(search_controller), :search)
      post("/.search", unquote(search_controller), :search_all)

      # Bulk operations endpoint - RFC 7644
      post("/Bulk", unquote(bulk_controller), :bulk)
    end
  end
end

# ExScimPhoenix

Phoenix integration for ExScim.

## Usage

Add SCIM routes to your Phoenix router:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :scim_api do
    plug :accepts, ["json", "scim+json"]
    plug ExScimPhoenix.Plugs.ScimContentType
    plug ExScimPhoenix.Plugs.ScimAuth
  end

  scope "/scim/v2" do
    pipe_through :scim_api
    use ExScimPhoenix.Router
  end
end
```



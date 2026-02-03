# ExScimEcto

Ecto storage adapter for ExScim.

## Configuration

```elixir
config :ex_scim,
  storage_strategy: ExScimEcto.StorageAdapter,
  storage_repo: MyApp.Repo,
  storage_schema: MyApp.Accounts.User
```


To preload associations:

```elixir
config :ex_scim,
  storage_repo: MyApp.Repo,
  user_model: {MyApp.Accounts.User, preload: [:roles, :organizations]},
  group_model: {MyApp.Groups.Group, preload: [:members]}
```

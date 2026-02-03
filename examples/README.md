# ExScim Examples

Example applications demonstrating SCIM 2.0 implementation with Elixir and Phoenix.

## Projects

### Provider

Example SCIM provider implementation. Demonstrates how to build a SCIM server that manages users and groups.

See [provider/README.md](provider/README.md) for setup instructions.

### Client

Example SCIM client implementation. Demonstrates how to interact with a SCIM provider.

See [client/README.md](client/README.md) for setup instructions.

## Development

Install dependencies and set up the database:

```bash
cd provider  # or client
mix deps.get
mix ecto.setup
mix phx.server
```

## License

See [LICENSE](LICENSE) file.

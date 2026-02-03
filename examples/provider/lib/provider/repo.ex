defmodule Provider.Repo do
  use Ecto.Repo,
    otp_app: :provider,
    adapter: Ecto.Adapters.SQLite3
end

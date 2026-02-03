defmodule Client.Repo do
  use Ecto.Repo,
    otp_app: :client,
    adapter: Ecto.Adapters.SQLite3
end

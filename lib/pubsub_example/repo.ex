defmodule PubsubExample.Repo do
  use Ecto.Repo,
    otp_app: :pubsub_example,
    adapter: Ecto.Adapters.Postgres
end

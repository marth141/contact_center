defmodule ContactCenter.Repo do
  use Ecto.Repo,
    otp_app: :contact_center,
    adapter: Ecto.Adapters.Postgres
end

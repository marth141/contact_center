defmodule ContactCenter.Repo.Migrations.AddCallLogTable do
  use Ecto.Migration

  def change do
    create table("call_logs") do
      add :account_sid, :string
      add :annotation, :string
      add :answered_by, :string
      add :api_version, :string
      add :caller_name, :string
      add :date_created, :string
      add :date_updated, :string
      add :direction, :string
      add :duration, :string
      add :end_time, :string
      add :forwarded_from, :string
      add :from, :string
      add :from_formatted, :string
      add :group_sid, :string
      add :parent_call_sid, :string
      add :phone_number_sid, :string
      add :price, :string
      add :price_unit, :string
      add :queue_time, :string
      add :sid, :string
      add :start_time, :string
      add :status, :string
      add :subresource_uris, :map
      add :to, :string
      add :to_formatted, :string
      add :trunk_sid, :string
      add :uri, :string
    end

    create unique_index("call_logs", [:sid])
  end
end

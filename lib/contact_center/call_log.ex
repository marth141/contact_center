defmodule ContactCenter.CallLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "call_logs" do
    field :account_sid, :string
    field :annotation, :string
    field :answered_by, :string
    field :api_version, :string
    field :caller_name, :string
    field :date_created, :string
    field :date_updated, :string
    field :direction, :string
    field :duration, :string
    field :end_time, :string
    field :forwarded_from, :string
    field :from, :string
    field :from_formatted, :string
    field :group_sid, :string
    field :parent_call_sid, :string
    field :phone_number_sid, :string
    field :price, :string
    field :price_unit, :string
    field :queue_time, :string
    field :sid, :string
    field :start_time, :string
    field :status, :string
    field :subresource_uris, :map
    field :to, :string
    field :to_formatted, :string
    field :trunk_sid, :string
    field :uri, :string
  end

  def changeset(call_log, params \\ %{}) do
    keys = get_param_atoms(params)

    call_log
    |> cast(params, keys)
    |> unique_constraint(:sid)
  end

  defp get_param_atoms(params) do
    Map.keys(params) |> Enum.map(&String.to_atom/1)
  end
end

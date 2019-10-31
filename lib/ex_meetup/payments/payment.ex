defmodule ExMeetup.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "payments" do
    field :amount, :decimal
    field :currency, :string
    field :state, :string
    field :value_date, :date
    belongs_to :user, ExMeetup.Admin.User

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :currency, :value_date, :state])
    |> validate_required([:amount, :currency, :value_date, :state])
  end
end

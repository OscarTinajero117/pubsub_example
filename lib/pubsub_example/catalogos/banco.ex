defmodule PubsubExample.Catalogos.Banco do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bancos" do
    field :descripcion, :string
    field :clabe, :string
    field :cant_open, :boolean, virtual: true, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(banco, attrs) do
    banco
    |> cast(attrs, [:descripcion, :clabe])
    |> validate_required([:descripcion, :clabe])
  end
end

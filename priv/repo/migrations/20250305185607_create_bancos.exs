defmodule PubsubExample.Repo.Migrations.CreateBancos do
  use Ecto.Migration

  def change do
    create table(:bancos) do
      add :descripcion, :string
      add :clabe, :string

      timestamps(type: :utc_datetime)
    end
  end
end

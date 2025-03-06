defmodule PubsubExample.CatalogosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PubsubExample.Catalogos` context.
  """

  @doc """
  Generate a banco.
  """
  def banco_fixture(attrs \\ %{}) do
    {:ok, banco} =
      attrs
      |> Enum.into(%{
        clabe: "some clabe",
        descripcion: "some descripcion"
      })
      |> PubsubExample.Catalogos.create_banco()

    banco
  end
end

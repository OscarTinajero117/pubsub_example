defmodule PubsubExample.CatalogosTest do
  use PubsubExample.DataCase

  alias PubsubExample.Catalogos

  describe "bancos" do
    alias PubsubExample.Catalogos.Banco

    import PubsubExample.CatalogosFixtures

    @invalid_attrs %{descripcion: nil, clabe: nil}

    test "list_bancos/0 returns all bancos" do
      banco = banco_fixture()
      assert Catalogos.list_bancos() == [banco]
    end

    test "get_banco!/1 returns the banco with given id" do
      banco = banco_fixture()
      assert Catalogos.get_banco!(banco.id) == banco
    end

    test "create_banco/1 with valid data creates a banco" do
      valid_attrs = %{descripcion: "some descripcion", clabe: "some clabe"}

      assert {:ok, %Banco{} = banco} = Catalogos.create_banco(valid_attrs)
      assert banco.descripcion == "some descripcion"
      assert banco.clabe == "some clabe"
    end

    test "create_banco/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogos.create_banco(@invalid_attrs)
    end

    test "update_banco/2 with valid data updates the banco" do
      banco = banco_fixture()
      update_attrs = %{descripcion: "some updated descripcion", clabe: "some updated clabe"}

      assert {:ok, %Banco{} = banco} = Catalogos.update_banco(banco, update_attrs)
      assert banco.descripcion == "some updated descripcion"
      assert banco.clabe == "some updated clabe"
    end

    test "update_banco/2 with invalid data returns error changeset" do
      banco = banco_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogos.update_banco(banco, @invalid_attrs)
      assert banco == Catalogos.get_banco!(banco.id)
    end

    test "delete_banco/1 deletes the banco" do
      banco = banco_fixture()
      assert {:ok, %Banco{}} = Catalogos.delete_banco(banco)
      assert_raise Ecto.NoResultsError, fn -> Catalogos.get_banco!(banco.id) end
    end

    test "change_banco/1 returns a banco changeset" do
      banco = banco_fixture()
      assert %Ecto.Changeset{} = Catalogos.change_banco(banco)
    end
  end
end

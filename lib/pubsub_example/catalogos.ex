defmodule PubsubExample.Catalogos do
  @moduledoc """
  The Catalogos context.
  """

  import Ecto.Query, warn: false
  alias PubsubExample.Repo

  alias PubsubExample.Catalogos.Banco

  alias Phoenix.PubSub

  @pubsub_topic "catalogos:bancos"

  @pubsub PubsubExample.PubSub

  def pubsub_topic, do: @pubsub_topic
  def pubsub, do: @pubsub

  @doc """
  Returns the list of bancos.

  ## Examples

      iex> list_bancos()
      [%Banco{}, ...]

  """
  def list_bancos do
    Repo.all(Banco)
  end

  @doc """
  Gets a single banco.

  Raises `Ecto.NoResultsError` if the Banco does not exist.

  ## Examples

      iex> get_banco!(123)
      %Banco{}

      iex> get_banco!(456)
      ** (Ecto.NoResultsError)

  """
  def get_banco!(id), do: Repo.get!(Banco, id)

  @doc """
  Creates a banco.

  ## Examples

      iex> create_banco(%{field: value})
      {:ok, %Banco{}}

      iex> create_banco(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_banco(attrs \\ %{}) do
    %Banco{}
    |> Banco.changeset(attrs)
    |> Repo.insert()

    # |> to_return(:create)
  end

  @doc """
  Updates a banco.

  ## Examples

      iex> update_banco(banco, %{field: new_value})
      {:ok, %Banco{}}

      iex> update_banco(banco, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_banco(%Banco{} = banco, attrs) do
    banco
    |> Banco.changeset(attrs)
    |> Repo.update()

    # |> to_return(:update)
  end

  @doc """
  Deletes a banco.

  ## Examples

      iex> delete_banco(banco)
      {:ok, %Banco{}}

      iex> delete_banco(banco)
      {:error, %Ecto.Changeset{}}

  """
  def delete_banco(%Banco{} = banco) do
    Repo.delete(banco)
    # |> to_return(:delete)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking banco changes.

  ## Examples

      iex> change_banco(banco)
      %Ecto.Changeset{data: %Banco{}}

  """
  def change_banco(%Banco{} = banco, attrs \\ %{}) do
    Banco.changeset(banco, attrs)
  end

  def broadcast_changed(schema, action) do
    PubSub.broadcast(@pubsub, @pubsub_topic, {action, schema})
  end

  def subscribe_changed do
    PubSub.subscribe(@pubsub, @pubsub_topic)
  end

  # Esta función se usa para notificar a los clientes de los cambios en la base de datos.
  #  Esto se hace desde el backend.
  #  Se usa cuando no se este utlizando PostgreSQL.
  # defp to_return(result, action) do
  #   case result do
  #     {:ok, schema} ->
  #       broadcast_changed(schema, action)
  #       {:ok, schema}

  #     error ->
  #       error
  #   end
  # end
end

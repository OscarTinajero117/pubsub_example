defmodule PubsubExample.Catalogos.Notifier do
  @moduledoc """
  Módulo que se encarga de notificar a los clientes de los cambios en
  la tabla de la base de datos.

  Cambios en caliente de la base de datos.

  Solo funciona con PostgreSQL.
  """
  use GenServer
  alias PubsubExample.Repo

  import PubsubExample.Catalogos

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, pid} = Postgrex.Notifications.start_link(Repo.config())
    Postgrex.Notifications.listen(pid, "bancos")
    {:ok, pid}
  end

  def handle_info({:notification, _pid, _ref, "bancos", payload} = _check, state) do
    case Jason.decode(payload) do
      {:ok, %{"tipo" => "INSERT", "id" => id}} ->
        schema = get_banco!(id)

        broadcast_changed(schema, :create)

      {:ok, %{"tipo" => "UPDATE", "id" => id}} ->
        schema = get_banco!(id)

        broadcast_changed(schema, :update)

      {:ok, %{"tipo" => "DELETE", "id_delete" => id}} ->
        broadcast_changed(%{id: id}, :delete)

      _ ->
        :ok
    end

    {:noreply, state}
  end
end

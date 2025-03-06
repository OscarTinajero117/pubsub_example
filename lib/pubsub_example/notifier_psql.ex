defmodule PubsubExample.NotifierPSQL do
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

# Una posible solución para el problema de consultar a las demás tablas:
# defmodule PubsubExample.NotifierPSQL do
#   @moduledoc """
#   Módulo que se encarga de notificar a los clientes de los cambios en
#   la base de datos en tiempo real usando PostgreSQL.

#   Funciona con las tablas: bancos, clientes, usuarios y bitacora.
#   """

#   use GenServer
#   alias PubsubExample.Repo

#   # Mapea el nombre de la tabla a su módulo correspondiente
#   @mappings %{
#     "bancos" => PubsubExample.Catalogos,
#     "clientes" => PubsubExample.Clientes,
#     "usuarios" => PubsubExample.Usuarios,
#     "bitacora" => PubsubExample.Bitacora
#   }

#   def start_link(_opts) do
#     GenServer.start_link(__MODULE__, nil, name: __MODULE__)
#   end

#   def init(_) do
#     {:ok, pid} = Postgrex.Notifications.start_link(Repo.config())
#     Postgrex.Notifications.listen(pid, "changes") # Ahora escucha todos los cambios
#     {:ok, pid}
#   end

#   def handle_info({:notification, _pid, _ref, "changes", payload}, state) do
#     case Jason.decode(payload) do
#       {:ok, %{"tabla" => tabla, "tipo" => tipo, "id" => id}} ->
#         handle_database_event(tabla, tipo, id)

#       _ ->
#         :ok
#     end

#     {:noreply, state}
#   end

#   defp handle_database_event(tabla, tipo, id) do
#     case Map.get(@mappings, tabla) do
#       nil ->
#         IO.puts("No hay módulo asignado para la tabla: #{tabla}")

#       modulo ->
#         case tipo do
#           "INSERT" -> broadcast_change(modulo, id, :create)
#           "UPDATE" -> broadcast_change(modulo, id, :update)
#           "DELETE" -> broadcast_change(modulo, id, :delete)
#           _ -> :ok
#         end
#     end
#   end

#   defp broadcast_change(modulo, id, action) do
#     schema =
#       case action do
#         :delete -> %{id: id} # No se puede recuperar un registro eliminado
#         _ -> apply(modulo, :"get_#{String.trim_trailing(tabla, "s")}_!", [id])
#       end

#     broadcast_changed(schema, action)
#   end
# end

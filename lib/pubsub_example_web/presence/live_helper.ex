defmodule PubsubExampleWeb.LiveHelper do
  @moduledoc """
   Este módulo proporciona helpers para la gestión de actualizaciones en listas dentro de
  aplicaciones Phoenix LiveView que utilizan PubSub para la comunicación en tiempo real.

  **Funcionalidades Principales:**

  1. **Broadcast de Actualizaciones de Listas:** Permite transmitir operaciones de inserción
    y eliminación de entidades en listas a través del sistema de PubSub de Phoenix.
    Los clientes LiveView suscritos a un topic específico pueden recibir estas actualizaciones
    en tiempo real.

  2. **Manejo de Actualizaciones en LiveView:** Proporciona funciones para integrar fácilmente
    las actualizaciones de listas recibidas a través de PubSub en streams de datos de LiveView.
    Utiliza las funciones `stream_insert` y `stream_delete` de Phoenix.LiveView para
    mantener la interfaz de usuario sincronizada con los cambios en la lista.

  3. **Control de Acciones de Entidades:** Ofrece funciones para habilitar y deshabilitar
    acciones asociadas a entidades. Esto se implementa a través de un campo booleano
    `cant_open` en la entidad, permitiendo controlar dinámicamente si una entidad puede
    ser interactuada (e.g., editada o abierta) por el usuario.

  **Uso Típico:**

  En una aplicación LiveView que muestra listas de datos actualizables en tiempo real,
  este módulo se utilizaría para:

  - Cuando un cambio en la lista ocurre en el servidor (e.g., una nueva entidad se crea,
   o una existente se elimina), utilizar `LiveHelper.broadcast/3` para notificar a todos
   los LiveViews conectados sobre el cambio.

  - En cada LiveView, manejar los mensajes de broadcast (`{:list_update, ...}`) en el
   callback `handle_info/2`, utilizando `LiveHelper.handle_list_update/3` para actualizar
   el stream de datos del LiveView y así reflejar el cambio en la interfaz de usuario.

  - Utilizar `LiveHelper.disable_entity_actions/1` y `LiveHelper.enable_entity_actions/1`
   para controlar el estado interactivo de las entidades en la lista, posiblemente basado
   en la lógica de negocio de la aplicación (e.g., para indicar que una entidad está siendo
   editada por otro usuario y no debe ser modificada simultáneamente).
  """
  alias PubsubExampleWeb.Endpoint

  import Phoenix.LiveView, only: [stream_insert: 4, stream_delete: 3]

  @stream_operations [:insert, :delete]
  @doc """
   Transmite una actualización de lista a través del Endpoint de Phoenix.

     Esta función se encarga de enviar un mensaje broadcast a todos los clientes
     suscritos al `topic` especificado. El mensaje indica una actualización de lista
     con la `operation` y la `entity` dadas.

     Utiliza `Endpoint.broadcast!` para asegurar que el mensaje se envíe de manera
     confiable a través del sistema de PubSub de Phoenix.

     Parámetros:
       - topic: El topic de PubSub al cual se enviará el mensaje. Los clientes LiveView
                deben estar suscritos a este topic para recibir actualizaciones.
       - operation: La operación que se está realizando en la lista. Debe ser uno de los
                    valores definidos en `@stream_operations` (e.g., `:insert`, `:delete`).
       - entity: La entidad que está siendo insertada o eliminada de la lista. Esta entidad
                 será transmitida a los clientes para que puedan actualizar su vista.

     Ejemplos:

         # Para insertar una nueva entidad en la lista con el topic "items:123"
         LiveHelper.broadcast("items:123", :insert, %{id: 4, name: "New Item"})

         # Para eliminar una entidad de la lista con el topic "items:123"
         LiveHelper.broadcast("items:123", :delete, %{id: 4})
  """
  def broadcast(topic, operation, entity) when operation in @stream_operations do
    Endpoint.broadcast!(topic, "list_update", {operation, entity})
  end

  @doc """
   Maneja las actualizaciones de lista recibidas a través del broadcast.

     Esta función está diseñada para ser utilizada como un handler dentro de un
     LiveView. Recibe una operación y una entidad, y utiliza `update_stream` para
     actualizar el stream de datos asociado al socket del LiveView.

     Permite opciones para controlar la posición de inserción (`:at`), un límite
     (aunque `limit` no se utiliza explícitamente en esta función en el código proporcionado),
     y el nombre del stream (`:name_stream`).

     Parámetros:
       - socket: El socket del LiveView actual.
       - operation: La operación de stream a realizar (`:insert` o `:delete`).
       - entity: La entidad a ser insertada o eliminada del stream.
       - opts: Una lista de keywords opcionales:
          - `:at`: Posición en la que se insertará la entidad en el stream (para `:insert`).
                   Por defecto es `0` (al principio del stream).
           - `:limit`:  Aunque presente, no se utiliza directamente en el código para limitar
                      el stream en esta función. Puede ser utilizado en otras partes de la app.
           - `:name_stream`: El nombre del stream a ser actualizado. Por defecto es `:collection`.
                            Este nombre debe corresponder al stream que se inicializó en el
                            LiveView utilizando `stream/3`.

     Ejemplos (dentro de un LiveView handle_info):

         def handle_info({:list_update, {:insert, entity}}, socket) do
           {:noreply, LiveHelper.handle_list_update(socket, :insert, entity)}
         end

         def handle_info({:list_update, {:delete, entity}}, socket) do
           {:noreply, LiveHelper.handle_list_update(socket, :delete, entity)}
         end
  """
  def handle_list_update(socket, operation, entity, opts \\ [])
      when operation in @stream_operations do
    at = Keyword.get(opts, :at, 0)
    limit = Keyword.get(opts, :limit)
    name_stream = Keyword.get(opts, :name_stream, :collection)

    update_stream(socket, operation, entity, name_stream, limit: limit, at: at)
  end

  defp update_stream(socket, :insert, entity, name_stream, opts),
    do: stream_insert(socket, name_stream, entity, opts)

  defp update_stream(socket, :delete, entity, name_stream, _opts),
    do: stream_delete(socket, name_stream, entity)

  @doc """
   Deshabilita las acciones de una entidad.

     Modifica la entidad para indicar que sus acciones están deshabilitadas.
     Esto se logra estableciendo el campo `:cant_open` de la entidad a `true`.
     El significado preciso de "deshabilitar acciones" depende del contexto de la aplicación,
     pero generalmente implica que la entidad no puede ser editada, abierta, etc.

     Parámetros:
       - entity: La entidad cuyas acciones se van a deshabilitar. Se espera que sea un mapa
                 o struct que tenga un campo modificable llamado `:cant_open`.

     Retorna:
       - Una nueva entidad (mapa o struct) con el campo `:cant_open` establecido a `true`.

     Ejemplos:

         entity = %{id: 1, name: "Item", cant_open: false}
         disabled_entity = LiveHelper.disable_entity_actions(entity)
          disabled_entity será: %{id: 1, name: "Item", cant_open: true}
  """
  def disable_entity_actions(entity) do
    %{entity | cant_open: true}
  end

  @doc """
    Habilita las acciones de una entidad.

    Modifica la entidad para indicar que sus acciones están habilitadas.
    Esto se logra estableciendo el campo `:cant_open` de la entidad a `false`.
    Revierte el efecto de `disable_entity_actions/1`.

    Parámetros:
      - entity: La entidad cuyas acciones se van a habilitar. Se espera que sea un mapa
                o struct que tenga un campo modificable llamado `:cant_open`.

    Retorna:
      - Una nueva entidad (mapa o struct) con el campo `:cant_open` establecido a `false`.

    Ejemplos:

        entity = %{id: 1, name: "Item", cant_open: true}
        enabled_entity = LiveHelper.enable_entity_actions(entity)
        enabled_entity será: %{id: 1, name: "Item", cant_open: false}
  """
  def enable_entity_actions(entity), do: %{entity | cant_open: false}
end

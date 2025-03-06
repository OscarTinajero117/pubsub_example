defmodule PubsubExampleWeb.UpdatesHelpers do
  @moduledoc """
  Módulo con funciones de ayuda para actualizar entidades de la lista.
  """
  alias PubsubExampleWeb.{Presence, LiveHelper}

  @doc """
    Función base para `update_list_actions`.
    Esta definición no tiene cuerpo y sirve como punto de entrada para el pattern matching.

    Parámetros:
      - list_items: Los items de la lista a ser actualizados.
      - topic: El topic o contexto dentro del cual la lista está siendo actualizada.

    Retorna:
      - Un mapa con la lista actualizada y el total_count original.
  """
  def update_list_actions(list_items, topic)

  def update_list_actions(%{list: list_items, total_count: total_count}, topic),
    do: %{list: update_list_actions(list_items, topic), total_count: total_count}

  def update_list_actions(list_items, topic),
    do: Enum.map(list_items, fn item -> update_entity_actions(item, topic) end)

  @doc """
   Función para actualizar las acciones de una entidad individual.

   Verifica si la entidad está siendo usada en el `topic` actual usando `Presence.entity_in_used`.
   Si está siendo usada, deshabilita las acciones de la entidad usando `LiveHelper.disable_entity_actions`.
   Si no está siendo usada, habilita las acciones de la entidad usando `LiveHelper.enable_entity_actions`.

   Parámetros:
     - entity: La entidad cuyas acciones serán actualizadas. Se espera que sea un struct o un mapa con un campo `:id`.
     - topic: El topic o contexto para verificar el uso de la entidad.
  """
  def update_entity_actions(entity, topic) do
    if Presence.entity_in_used(topic, entity.id) do
      LiveHelper.disable_entity_actions(entity)
    else
      LiveHelper.enable_entity_actions(entity)
    end
  end

  @doc """
   Función para generar un mensaje de error indicando que una entidad está siendo editada por un usuario.

     Extrae la descripción de la entidad usando `get_atom` y el `atom_name` proporcionado (o "descripcion" por defecto).
     Incluye el email del usuario en el mensaje para indicar quién está editando la entidad.

     Parámetros:
       - entity: La entidad que está siendo editada. Se espera que tenga un campo de descripción.
       - _user: Un mapa que representa al usuario. Se extrae el email de este mapa.
       - atom_name: El nombre del átomo (campo) que contiene la descripción de la entidad. Por defecto es "descripcion".

     Retorna:
       - Un string con el mensaje de error.
  """
  def error_message(entity, %{email: email} = _user, atom_name \\ "descripcion") do
    descripcion = get_atom(entity, atom_name)
    "#{descripcion} está siendo editado por #{email}"
  end

  defp get_atom(entity, string), do: Map.get(entity, String.to_atom(string))
end

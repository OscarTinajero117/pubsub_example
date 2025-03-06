defmodule PubsubExampleWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html) module for more information.

  This module extends `Phoenix.Presence` to track which users are currently interacting with specific entities within the application.
  It is designed to be used in conjunction with Phoenix Channels and LiveView to provide real-time updates
  about entity usage, enabling features like collaborative editing indicators or preventing concurrent modifications.

  It leverages `Phoenix.Presence` to manage the underlying presence data and provides helper functions
  to track users' involvement with entities and query the current usage status of entities.
  """

  use Phoenix.Presence,
    otp_app: :pubsub_example,
    pubsub_server: PubsubExample.PubSub

  alias PubsubExampleWeb.LiveHelper

  @doc """
     User-defined state initialization for Presence.

     In this case, the state is initialized as an empty map, which is not directly used
     by the Presence module itself but is part of the required callback structure for `Phoenix.Presence`.

     This function is called when the Presence tracker is started.

     Parámetros:
       - _opts: Options passed during initialization (not used in this implementation).

     Retorna:
       - {:ok, state}: Returns `:ok` tuple with the initial state (an empty map).
  """
  def init(_opts), do: {:ok, %{}}

  @doc """
   Handles presence meta updates, specifically for joins and leaves.

   This function is a callback for `Phoenix.Presence`. It is invoked when presence meta information
   changes for a given `topic`. It processes both user joins and leaves within the topic.
   For each join and leave event, it calls `broadcast_entity_update/2` to notify clients about the change
   in entity usage.

   Parámetros:
     - topic: The topic for which presence updates occurred.
     - %{joins: joins, leaves: leaves}: A map containing two keys:
         - `:joins`: A list of presence records for users who joined the topic.
         - `:leaves`: A list of presence records for users who left the topic.
     - _presences: The current presence state before the update (not used in this implementation).
     - state: The current user-defined state (from `init/1`), passed through unchanged.

   Retorna:
     - {:ok, state}: Returns `:ok` tuple with the unchanged state.
  """
  def handle_metas(topic, %{joins: joins, leaves: leaves}, _presences, state) do
    for {_user_id, presence} <- joins, do: broadcast_entity_update(topic, presence)
    for {_user_id, presence} <- leaves, do: broadcast_entity_update(topic, presence)

    {:ok, state}
  end

  defp broadcast_entity_update(topic, presence) do
    metas = List.first(presence.metas)

    LiveHelper.broadcast(topic, :insert, metas.entity)
  end

  @doc """
   Tracks a user's live presence associated with an entity.

   This function is used to start tracking a user's presence in a given `topic`
   and associate it with a specific `entity`. It calls `Phoenix.Presence.track/4`
   to register the presence, including metadata about the entity and the current user.

   Parámetros:
     - pid: The process ID (PID) of the process that is tracking presence (e.g., a Channel or LiveView process).
     - topic: The topic under which presence is being tracked.
     - current_user: A struct or map representing the current user, expected to have `:id` and `:email` fields.
     - entity: The entity the user is interacting with. This entity will be included in the presence metadata.
  """
  def track_live_entity(pid, topic, current_user, entity) do
    track(
      pid,
      topic,
      current_user.id,
      %{
        entity: entity,
        email: current_user.email,
        id_usuario: current_user.id
      }
    )
  end

  @doc """
   Updates a user's live presence metadata associated with an entity.

   This function is used to update the metadata of an existing presence record for a user in a given `topic`.
   It calls `Phoenix.Presence.update/4` to modify the presence information, typically used when the
   user's interaction with an entity changes (e.g., editing content).

   Parámetros:
     - pid: The process ID (PID) of the process that is updating presence.
     - topic: The topic under which presence is being tracked.
     - current_user: A struct or map representing the current user.
     - entity: The updated entity information to be reflected in the presence metadata.
  """
  def update_live_entity(pid, topic, current_user, entity) do
    update(
      pid,
      topic,
      current_user.id,
      %{
        entity: entity,
        email: current_user.email,
        id_usuario: current_user.id
      }
    )
  end

  @doc """
  Returns a map of used entities for a given topic with the email
  and id of the user for each used entity in the list.
  """
  def filter_use_of_entities(topic) do
    enum =
      topic
      |> list()
      |> Enum.map(fn {_, v} ->
        v.metas
        |> Enum.into(%{}, fn m -> {m.entity.id, %{email: m.email, id: m.id_usuario}} end)
      end)

    if Enum.empty?(enum) do
      %{}
    else
      Enum.reduce(enum, &Map.merge/2)
    end
  end

  @doc """
  Checks the `precense_map`for the èntity.id``
  When found, it returns a map with the user's `email`, and `id`.
  It returns `false`otherwise.

  ## Examples
  // The entity with id 10 is used by the user "admin"
  iex> entity_in_used(presence_map, 10)
  %{id: 1, email: "admin@admin"}

  // The entity with id 11 is not used by anyone
  iex> entity_in_used(precense_map, 11)
  false

  // Also works by passing the topic instead of the presence list
  iex> entity_in_used("some_topic", 10)
  %{id: 1, email: "admin@admin"}
  """

  def entity_in_used(topic, entity_id) when is_binary(topic) do
    topic |> filter_use_of_entities() |> entity_in_used(entity_id)
  end

  def entity_in_used(presence_map, entity_id) do
    entity_id = if is_binary(entity_id), do: String.to_integer(entity_id), else: entity_id

    case Map.get(presence_map, entity_id) do
      nil -> false
      user -> user
    end
  end
end

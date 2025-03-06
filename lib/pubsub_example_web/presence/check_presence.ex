defmodule PubsubExampleWeb.CheckPresence do
  @moduledoc """
  Provides functions to check user presence before allowing actions on entities.

  This module is designed to integrate with `PubsubExampleWeb.Presence` to ensure
  that actions on entities are performed in a presence-aware manner. It checks
  if an entity is currently being used by another user and, based on the presence
  status, either allows the action to proceed or prevents it, providing user feedback
  via flash messages.

  It is typically used within Phoenix controllers or LiveViews to guard actions that
  should not be performed concurrently by different users on the same entity.
  """
  import Phoenix.Controller,
    only: [put_flash: 3]

  alias PubsubExampleWeb.{Presence, UpdatesHelpers}

  @doc """
  Checks user presence for an entity and returns the appropriate socket.

  This function determines if an entity is currently being used by another user
  by consulting `PubsubExampleWeb.Presence.entity_in_used/2`. Based on the
  presence check and whether the current user is the same user already using the entity,
  it returns either `socket_yes` to proceed with the action or `socket_no` to indicate
  that the action cannot be performed due to presence constraints.

  If the entity is not in use, it tracks the current user's presence using
  `PubsubExampleWeb.Presence.track_live_entity/4`.

  If the entity is in use by a different user, it adds an error flash message to `socket_no`
  informing the user about the conflict.

  ## Parameters:

  - `entity`: The entity to check presence for. It should be a struct or map that has an `:id` field.
  - `usuario`: The current user performing the action. It should be a struct or map that has `:email` and `:id` fields.
  - `socket_yes`: The socket to return if the presence check allows the action to proceed (entity not in use or used by the same user).
  - `socket_no`: The socket to return if the presence check prevents the action (entity is in use by a different user).
  - `_same_id`: A boolean flag (intended to be `false` in this function definition). It's used in pattern matching to differentiate this function definition.  In this particular definition, it's explicitly matched against `false`, suggesting this path is taken when the intention is to perform the full presence check logic.
  - `topic`: The presence topic under which entity usage is being tracked.
  - `pid`: The process ID (PID) of the process managing presence (e.g., LiveView process or Channel).

  ## Returns:

  - `socket_yes`: If the entity is not in use or is being used by the same user. In this case, the action on the entity can proceed.
  - `socket_no`: If the entity is being used by a different user. In this case, the action should be prevented, and an error flash message is added to the socket.
  """
  def check_presence(entity, usuario, socket_yes, socket_no, false = _same_id, topic, pid) do
    if user = Presence.entity_in_used(topic, entity.id) do
      if user.email != usuario.email do
        error = UpdatesHelpers.error_message(entity, user)

        socket_no
        |> put_flash(:error, error)
      else
        socket_yes
      end
    else
      Presence.track_live_entity(pid, topic, usuario, entity)

      socket_yes
    end
  end

  def check_presence(_entity, _usuario, socket_yes, _socket_no, true, _topic, _pid),
    do: socket_yes
end

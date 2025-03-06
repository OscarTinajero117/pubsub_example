defmodule PubsubExampleWeb.BancoLive.Index do
  use PubsubExampleWeb, :live_view

  alias PubsubExample.Catalogos
  alias PubsubExample.Catalogos.Banco

  alias PubsubExampleWeb.{Endpoint, Presence, UpdatesHelpers, CheckPresence, LiveHelper}

  def topic(), do: Catalogos.pubsub_topic()

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Catalogos.subscribe_changed()

      topic()
      |> Endpoint.subscribe()
    end

    {:ok, stream(socket, :collection, list_schemas())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    banco = Catalogos.get_banco!(id)

    CheckPresence.check_presence(
      banco,
      socket.assigns.current_user,
      socket
      |> assign(:page_title, "Edit Banco")
      |> assign(:banco, banco),
      socket |> push_patch(to: ~p"/bancos"),
      false,
      topic(),
      self()
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Banco")
    |> assign(:banco, %Banco{})
  end

  defp apply_action(socket, :index, _params) do
    # IO.inspect(socket.assigns.current_user)
    Presence.untrack(self(), topic(), socket.assigns.current_user.id)

    socket
    |> assign(:page_title, "Listing Bancos")
    |> assign(:banco, nil)
  end

  @impl true
  def handle_info({:create, banco}, socket) do
    {:noreply, stream_insert(socket, :collection, banco)}
  end

  def handle_info({:update, banco}, socket) do
    {:noreply, stream_insert(socket, :collection, banco, at: -1)}
  end

  def handle_info({:delete, %{id: id}}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :collection, "collection-#{id}")}
  end

  def handle_info(%{event: "list_update", payload: {operation, entity}}, socket) do
    entity = UpdatesHelpers.update_entity_actions(entity, topic())

    {:noreply, LiveHelper.handle_list_update(socket, operation, entity)}
  end

  def handle_info(%{event: "presence_diff"}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    banco = Catalogos.get_banco!(id)
    {:ok, _} = Catalogos.delete_banco(banco)

    {:noreply, socket}
  end

  defp list_schemas(), do: Catalogos.list_bancos() |> UpdatesHelpers.update_list_actions(topic())
end

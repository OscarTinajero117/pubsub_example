defmodule PubsubExampleWeb.BancoLive.Show do
  use PubsubExampleWeb, :live_view

  alias PubsubExample.Catalogos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:banco, Catalogos.get_banco!(id))}
  end

  defp page_title(:show), do: "Show Banco"
  defp page_title(:edit), do: "Edit Banco"
end

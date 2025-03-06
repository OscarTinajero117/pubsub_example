defmodule PubsubExampleWeb.BancoLive.FormComponent do
  use PubsubExampleWeb, :live_component

  alias PubsubExample.Catalogos

  import PubsubExampleWeb.BancoLive.Index, only: [topic: 0]

  alias PubsubExampleWeb.{Presence, LiveHelper}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage banco records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="banco-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:descripcion]} type="text" label="Descripcion" />
        <.input field={@form[:clabe]} type="text" label="Clabe" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Banco</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{banco: banco} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Catalogos.change_banco(banco))
     end)}
  end

  @impl true
  def handle_event("validate", %{"banco" => banco_params}, socket) do
    changeset = Catalogos.change_banco(socket.assigns.banco, banco_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"banco" => banco_params}, socket) do
    save_banco(socket, socket.assigns.action, banco_params)
  end

  defp save_banco(socket, :edit, banco_params) do
    case Catalogos.update_banco(socket.assigns.banco, banco_params) do
      {:ok, banco} ->
        Presence.update_live_entity(
          self(),
          topic(),
          socket.assigns.current_user,
          banco
        )

        # notify_parent({:saved, banco})

        {:noreply,
         socket
         |> put_flash(:info, "Banco updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_banco(socket, :new, banco_params) do
    case Catalogos.create_banco(banco_params) do
      {:ok, banco} ->
        LiveHelper.broadcast(topic(), :insert, banco)
        # notify_parent({:saved, banco})

        {:noreply,
         socket
         |> put_flash(:info, "Banco created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

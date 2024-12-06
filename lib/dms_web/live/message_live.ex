defmodule DmsWeb.MessageLive do
  use DmsWeb, :live_view

  def mount(_params, _session, socket) do
    messages = Dms.MessageServer.get_messages()  # Récupérer les messages
    {:ok, assign(socket, :messages, messages)}  # Assigner les messages à la vue
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    Dms.MessageServer.send_message(message)  # Envoi du message au serveur

    # Mettre à jour la liste des messages après l'envoi
    messages = Dms.MessageServer.get_messages()
    {:noreply, assign(socket, :messages, messages)}
  end

  # La fonction render pour afficher le template HTML directement
  def render(assigns) do
    ~H"""
    <h1>Messagerie</h1>

    <ul>
      <%= for message <- @messages do %>
        <li><%= message %></li>
      <% end %>
    </ul>

    <form phx-submit="send_message">
      <input type="text" name="message" placeholder="Tapez votre message" />
      <button type="submit">Envoyer</button>
    </form>
    """
  end
end

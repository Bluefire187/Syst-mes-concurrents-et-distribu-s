defmodule DmsWeb.MessageLive do
  use DmsWeb, :live_view

  def mount(_params, _session, socket) do
    # L'utilisateur n'est pas encore connecté, donc user_id est nil
    user_id = nil

    # Initialise une liste de messages vide par défaut
    messages = []

    # S'abonner aux événements de nouveaux messages
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Dms.PubSub, "messages:updates")
    end

    {:ok, assign(socket, messages: messages, user_id: user_id)}
  end


  def handle_event("send_message", %{"message" => content}, socket) do
    IO.puts("Handling send_message event with content: #{content}")

    sender_id = socket.assigns[:user_id] || 1
    receiver_id = 2

    case Dms.MessageServer.send_message(content, sender_id, receiver_id, socket.id) do
      {:ok, _message} ->
        IO.puts("Message sent successfully")
        messages = Dms.MessageServer.get_messages(sender_id)
        {:noreply, assign(socket, :messages, messages)}

      {:error, changeset} ->
        IO.puts("Failed to send message: #{inspect(changeset.errors)}")
        {:noreply, socket}
    end
  end

  def handle_event("set_username", %{"username" => username}, socket) do
    case Dms.Accounts.get_or_create_user(username) do
      {:ok, user} ->
        # Récupérer les messages une fois connecté
        messages = Dms.MessageServer.get_messages(user.id)

        {:noreply, assign(socket, user_id: user.id, messages: messages)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end



  def handle_info({:new_message, message, sender_socket_id}, socket) do
    # Ignorer le message si le socket ID est celui de l'expéditeur
    if sender_socket_id != socket.id do
      messages = [message | socket.assigns.messages]
      {:noreply, assign(socket, :messages, messages)}
    else
      {:noreply, socket}
    end
  end



  def render(assigns) do
    ~H"""
    <%= if @user_id do %>
      <h1>Messagerie</h1>

      <ul>
        <%= for message <- Enum.reverse(@messages) do %>
          <li>
            <strong>Message :</strong> <%= message.content %> <br>
            <strong>De :</strong> <%= message.sender_id %> <br>
            <strong>À :</strong> <%= message.receiver_id %> <br>
            <strong>Envoyé le :</strong> <%= message.inserted_at |> Timex.format!("{0D}-{0M}-{YYYY} {h24}:{m}:{s}") %>
          </li>
        <% end %>
      </ul>

      <form phx-submit="send_message">
        <input type="text" name="message" placeholder="Tapez votre message" />
        <button type="submit">Envoyer</button>
      </form>
    <% else %>
      <h1>Connexion</h1>
      <form phx-submit="set_username">
        <input type="text" name="username" placeholder="Entrez votre nom d'utilisateur" />
        <button type="submit">Se connecter</button>
      </form>
    <% end %>
    """

  end
end

defmodule DmsWeb.MessageLive do
  use DmsWeb, :live_view
  alias Dms.Repo


  def mount(_params, _session, socket) do
    if connected?(socket) do
      # S'abonner au chat général
      Phoenix.PubSub.subscribe(Dms.PubSub, "chat:general")
    end

    # Récupérer les anciens messages pour le chat général (user_id = nil)
    messages = Dms.MessageServer.get_messages(nil)

    {:ok, assign(socket, messages: messages, user_id: nil)}
  end





  def handle_event("send_message", %{"message" => content}, socket) do
    IO.puts("Handling send_message event with content: #{content}")

    sender_id = socket.assigns[:user_id] || 1

    # Créer le message (enregistrer dans la DB si nécessaire)
    case Dms.MessageServer.send_message(content, sender_id, nil, socket.id) do
      {:ok, message} ->
        IO.puts("Message sent successfully")

        # Diffuser le message à tous les abonnés du chat général
        Phoenix.PubSub.broadcast(Dms.PubSub, "chat:general", {:new_message, message, socket.id})

        {:noreply, socket}

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



  def handle_info({:new_message, message, _sender_socket_id}, socket) do
    # Forcer le préchargement de :user au cas où
    message_with_user = Repo.preload(message, :user)

    # Vérifier si le message existe déjà dans la liste
    messages =
      if Enum.find(socket.assigns.messages, fn m -> m.id == message_with_user.id end) do
        # Si le message existe, ne rien changer
        socket.assigns.messages
      else
        # Ajouter le message à la liste des messages existants
        [message_with_user | socket.assigns.messages]
      end

    {:noreply, assign(socket, :messages, messages)}
  end






  def render(assigns) do
    ~H"""
    <%= if @user_id do %>
      <h1>Messagerie</h1>

      <ul>
        <%= for message <- Enum.reverse(@messages) do %>
          <li>
            <strong>Message :</strong> <%= message.content %> <br>
            <strong>De :</strong> <%= message.user.username %> <br>
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

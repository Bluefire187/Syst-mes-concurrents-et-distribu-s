defmodule Dms.MessageServer do
  use GenServer
  alias Dms.Repo
  alias Dms.Message
  import Ecto.Query  # Import nécessaire pour utiliser `from`

  # Fonction pour démarrer le GenServer
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Initialisation du cache
  def init(_args) do
    # Charger les messages récents depuis PostgreSQL dans le cache
    messages = Repo.all(from m in Message, order_by: [desc: m.inserted_at], limit: 50)
    {:ok, messages}
  end

  # Fonction pour envoyer un message (sauvegarde en base + ajout au cache)
  def send_message(content, sender_id, receiver_id, socket_id) do
    IO.puts("Sending message: #{content} from user #{sender_id} to user #{receiver_id}")

    changeset = Message.changeset(%Message{}, %{
      content: content,
      sender_id: sender_id,
      user_id: sender_id,
      receiver_id: nil
    })

    case Repo.insert(changeset) do
      {:ok, message} ->
        IO.puts("Message saved: #{inspect(message)}")

        # Précharger l'association :user pour inclure l'utilisateur
        message_with_user = Repo.preload(message, :user)

        # Diffuser à tous les abonnés du chat général
        Phoenix.PubSub.broadcast(Dms.PubSub, "chat:general", {:new_message, message_with_user, socket_id})

        GenServer.cast(__MODULE__, {:cache_message, message_with_user})
        {:ok, message}

      {:error, changeset} ->
        IO.puts("Failed to save message: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end



  # Fonction pour récupérer les messages pour un utilisateur
  def get_messages(user_id) do
    messages = GenServer.call(__MODULE__, {:get_messages, user_id})

    # Précharger l'association :user pour chaque message
    messages_with_users = Enum.map(messages, &Repo.preload(&1, :user))

    IO.puts("Messages fetched for user #{user_id || "general"}: #{inspect(messages_with_users)}")
    messages_with_users
  end

  # Adapter le handle_call pour gérer le cas user_id = nil
  def handle_call({:get_messages, user_id}, _from, state) do
    user_messages =
      Enum.filter(state, fn m ->
        user_id == nil or m.receiver_id == nil or m.sender_id == user_id or m.receiver_id == user_id
      end)

    {:reply, user_messages, state}
  end







  # Callbacks GenServer

  # Ajouter un message au cache
  def handle_cast({:cache_message, message}, state) do
    IO.puts("Caching message: #{inspect(message)}")
    new_state = [message | state] |> Enum.take(50)  # Limiter le cache à 50 messages
    {:noreply, new_state}
  end

end

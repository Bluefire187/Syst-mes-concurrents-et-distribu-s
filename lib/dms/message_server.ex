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
  def send_message(content, sender_id, receiver_id) do
    IO.puts("Sending message: #{content} from user #{sender_id} to user #{receiver_id}")

    changeset = Message.changeset(%Message{}, %{
      content: content,
      sender_id: sender_id,
      receiver_id: receiver_id
    })

    case Repo.insert(changeset) do
      {:ok, message} ->
        IO.puts("Message saved: #{inspect(message)}")
        GenServer.cast(__MODULE__, {:cache_message, message})
        {:ok, message}
      {:error, changeset} ->
        IO.puts("Failed to save message: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end


  # Fonction pour récupérer les messages pour un utilisateur
  def get_messages(user_id) do
    messages = GenServer.call(__MODULE__, {:get_messages, user_id})

    IO.puts("Messages fetched for user #{user_id}: #{inspect(messages)}")
    messages
  end




  # Callbacks GenServer

  # Ajouter un message au cache
  def handle_cast({:cache_message, message}, state) do
    IO.puts("Caching message: #{inspect(message)}")
    new_state = [message | state] |> Enum.take(50)  # Limiter le cache à 50 messages
    {:noreply, new_state}
  end

  # Récupérer les messages du cache pour un utilisateur
  def handle_call({:get_messages, user_id}, _from, state) do
    # Filtrer les messages par utilisateur
    user_messages =
      Enum.filter(state, fn m ->
        m.sender_id == user_id or m.receiver_id == user_id
      end)

    IO.puts("Messages fetched for user #{user_id}: #{inspect(user_messages)}")
    {:reply, user_messages, state}
  end


end

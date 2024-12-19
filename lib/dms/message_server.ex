defmodule Dms.MessageServer do
  use GenServer
  alias Dms.Repo
  alias Dms.Message
  import Ecto.Query

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Phoenix.PubSub.subscribe(Dms.PubSub, "chat:general")
    messages = Repo.all(from m in Message, order_by: [desc: m.inserted_at], limit: 50)
    {:ok, messages}
  end

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

        message_with_user = Repo.preload(message, :user)

        Phoenix.PubSub.broadcast(Dms.PubSub, "chat:general", {:new_message, message_with_user, socket_id})

        GenServer.cast(__MODULE__, {:cache_message, message_with_user})
        {:ok, message}

      {:error, changeset} ->
        IO.puts("Failed to save message: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end


  def get_messages(user_id) do
    messages = GenServer.call(__MODULE__, {:get_messages, user_id})

    messages_with_users = Enum.map(messages, &Repo.preload(&1, :user))

    IO.puts("Messages fetched for user #{user_id || "general"}: #{inspect(messages_with_users)}")
    messages_with_users
  end

  def handle_call({:get_messages, user_id}, _from, state) do
    user_messages =
      Enum.filter(state, fn m ->
        user_id == nil or m.receiver_id == nil or m.sender_id == user_id or m.receiver_id == user_id
      end)

    {:reply, user_messages, state}
  end

  def handle_call({:load_older_messages, oldest_message_timestamp}, _from, state) do
    IO.puts("Fetching messages older than: #{inspect(oldest_message_timestamp)}")

    older_messages = Repo.all(
      from m in Message,
      where: m.inserted_at < ^oldest_message_timestamp,
      order_by: [desc: m.inserted_at],
      limit: 500
    )
    |> Repo.preload(:user)

    IO.puts("Found older messages: #{length(older_messages)}")
    IO.inspect(older_messages)

    {:reply, older_messages, state}
  end


  def handle_info({:new_message, message, _socket_id}, state) do
    IO.puts("Received message on #{Node.self()}: #{inspect(message)}")
    new_state = [message | state] |> Enum.take(50)
    {:noreply, new_state}
  end


  def handle_cast({:cache_message, message}, state) do
    IO.puts("Caching message: #{inspect(message)}")
    new_state = [message | state] |> Enum.take(50)
    {:noreply, new_state}
  end

end

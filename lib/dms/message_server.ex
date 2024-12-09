defmodule Dms.MessageServer do
  use GenServer

  # Fonction pour démarrer le GenServer
  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  # Callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:send_message, message}, state) do
    {:noreply, [message | state]}  # Ajouter le message à l'état
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, state, state}  # Retourner les messages stockés dans l'état
  end

  # Fonction publique pour obtenir les messages
  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

  # Fonction pour envoyer un message
  def send_message(message) do
    GenServer.cast(__MODULE__, {:send_message, message})
  end
end

# 1. **ChatRoom Module**
#   Implement a `ChatRoom` module that uses GenServer to represent a single chat room. Each chat room should support:
#  - **User Management**: Users should be able to join and leave the room. Keep track of users currently in the room.
#  - **Messaging**: Users should be able to send messages to the chat room. Each message should include the sender’s name and a timestamp.
#  - **Message History**: Maintain a history of messages sent to the chat room, which can be retrieved on request.
defmodule ChatRoom do
  use GenServer
  # Client side
  def join(pid) do
  end

  def send_message(pid, sender_name, message) do
    GenServer.cast(pid, {:message, {pid, sender_name}, message})
  end


  @impl true
  # initialize gen server
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:message, {sender, sender_name}, data}, %{"name" => name} = state) do
    IO.puts("(#{name}): Received a message from #{sender_name}: #{data}")

    GenServer.cast(
      sender,
      {:received, {self(), state["name"]}, "Thank you for the message, #{sender_name}"}
    )

    {
      :noreply,
      state
      |> Map.update("history", [], fn history -> history ++ [{sender, data}] end)
    }
  end

  @impl true
  def handle_cast({:received, {_receiver, receiver_name}, data}, %{"name" => name} = state) do
    IO.puts("(#{name}): #{receiver_name} received my message and replied with: #{data}")
    {:noreply, state}
  end
end

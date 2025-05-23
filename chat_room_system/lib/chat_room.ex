defmodule ChatRoom do
  @moduledoc """
  Represents a single chat room
  """
  use GenServer

  @doc """

  """
  def start_link(name) do
    IO.puts("Starting chat room #{name} ...")
    GenServer.start_link(__MODULE__, %{}, name: via_tuple(name))
  end

  @doc """

  """
  def child_spec(name) do
    %{
      id: name,
      restart: :transient,
      shutdown: 5000,
      start: {__MODULE__, :start_link, [name]},
      type: :worker
    }
  end

  # client
  def join(room_id, user_id), do: GenServer.cast(room_id, {:join, user_id})
  def leave(room_id, user_id), do: GenServer.cast(room_id, {:leave, user_id})
  def get_message_history(room_id, user_id), do: GenServer.call(room_id, {:history, user_id})

  def send_message(room_id, %Message{} = msg) do
    GenServer.call(room_id, {:send_message, msg})
  end

  # callbacks
  @doc """

  """
  @impl true
  def init(_state) do
    {:ok, %Chat{messages: [], participants: []}}
  end

  @doc """

  """
  @impl true
  def handle_cast({:join, user_id}, state) do
    new_participants = Enum.uniq([user_id | state.participants])
    {:noreply, %Chat{state | participants: new_participants}}
  end

  @doc """

  """
  @impl true
  def handle_cast({:leave, user_id}, state) do
    new_participants = List.delete(state.participants, user_id)
    {:noreply, %Chat{state | participants: new_participants}}
  end

  @doc """

  """
  @impl true
  def handle_call({:history, user_id}, _from, state) do
    if user_id in state.participants do
      {:reply, {:ok, Enum.sort_by(state.messages, fn msg -> msg.timestamp end)}, state}
    else
      {:reply, {:error, :unauthorized}, state}
    end
  end

  @impl true
  def handle_call(
        {:send_message, %Message{sender_id: user_id, content: content}},
        _from,
        state
      ) do
    if user_id in state.participants do
      msg = %Message{
        message_id: UUID.uuid1(),
        sender_id: user_id,
        content: content,
        timestamp: DateTime.utc_now()
      }

      new_state = %Chat{state | messages: [msg | state.messages]}
      {:reply, :ok, new_state}
    else
      {:reply, {:error, :unauthorized}, state}
    end
  end

  defp via_tuple(name), do: {:via, Registry, {:chat_room_registry, name}}
end

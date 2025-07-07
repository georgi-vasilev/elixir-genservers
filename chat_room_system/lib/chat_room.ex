defmodule ChatRoom do
  @moduledoc """
  Represents a single chat room GenServer responsible for managing participants
  and messages within that room.
  """
  use GenServer

  @doc """
  Starts the chat room GenServer.

  ## Parameters

    - `name`: The unique identifier for the chat room. This is used for
      registering the GenServer via `Registry`.

  ## Returns

    - `{:ok, pid}` if the server started successfully.
    - `{:error, {:already_started, pid}}` if a chat room with the same name is already running.
    - `{:error, reason}` for other errors during startup.
  """
  def start_link(name) do
    IO.puts("Starting chat room #{name} ...")
    GenServer.start_link(__MODULE__, %{}, name: via_tuple(name))
  end

  @doc """
  Returns a child specification for this GenServer, suitable for use in a supervisor.

  ## Parameters

    - `name`: The unique identifier for the chat room, which will be used as the child's `id`.

  ## Returns

    A map representing the child specification.
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
  @doc """
  Allows a user to join the chat room.

  This is an asynchronous cast operation.

  ## Parameters

    - `room_id`: The identifier of the chat room (can be the PID or the name used in `via_tuple`).
    - `user_id`: The identifier of the user joining the room.
  """
  def join(room_id, user_id), do: GenServer.cast(room_id, {:join, user_id})

  def leave(room_id, user_id), do: GenServer.cast(room_id, {:leave, user_id})

  @doc """
  Retrieves the message history for a user in a specific chat room.
  The user must be a participant in the room.

  ## Parameters

    - `room_id`: The identifier of the chat room (can be the PID or the name used in `via_tuple`).
    - `user_id`: The identifier of the user requesting the history.

  ## Returns

    - `{:ok, list_of_messages}`: If the user is authorized, returns a sorted list of messages.
    - `{:error, :unauthorized}`: If the user is not a participant in the room.
    - Other `GenServer.call/3` return values on timeout or errors.
  """
  def get_message_history(room_id, user_id), do: GenServer.call(room_id, {:history, user_id})

  def send_message(room_id, %Message{} = msg) do
    GenServer.call(room_id, {:send_message, msg})
  end

  # Callbacks

  @doc """
  Initializes the chat room state.

  Sets up an empty list of messages and participants.
  """
  @impl true
  def init(_state) do
    {:ok, %Chat{messages: [], participants: []}}
  end

  @doc """
  Handles the `:join` cast. Adds a participant to the chat room and ensures participants are unique.

  ## Parameters

    - `message`: A tuple `{:join, user_id}` where `user_id` is the identifier of the user to add.
    - `state`: The current state of the GenServer (`%Chat{}`).

  ## Returns

    - `{:noreply, new_state}`: With the `user_id` added to the `participants` list.
  """
  @impl true
  def handle_cast({:join, user_id}, state) do
    new_participants = Enum.uniq([user_id | state.participants])
    {:noreply, %Chat{state | participants: new_participants}}
  end

  @doc """
  Handles the `:leave` cast. Lets a participant leave the chat room.

  ## Parameters

    - `message`: A tuple `{:leave, user_id}` where `user_id` is the identifier of the user to remove.
    - `state`: The current state of the GenServer (`%Chat{}`).

  ## Returns

    - `{:noreply, new_state}`: With the `user_id` removed from the `participants` list.
  """
  @impl true
  def handle_cast({:leave, user_id}, state) do
    new_participants = List.delete(state.participants, user_id)
    {:noreply, %Chat{state | participants: new_participants}}
  end

  @doc """
  Handles the `:history` call. Returns the chat message history to an user that is part
  of the chat room. Messages are sorted by timestamp.

  ## Parameters

    - `message`: A tuple `{:history, user_id}` where `user_id` is the identifier of the user requesting history.
    - `_from`: The GenServer `from` argument (caller's PID and tag).
    - `state`: The current state of the GenServer (`%Chat{}`).

  ## Returns

    - `{:reply, {:ok, sorted_messages}, new_state}`: If `user_id` is a participant.
    - `{:reply, {:error, :unauthorized}, new_state}`: If `user_id` is not a participant.
  """
  @impl true
  def handle_call({:history, user_id}, _from, state) do
    if user_id in state.participants do
      {:reply, {:ok, Enum.sort_by(state.messages, fn msg -> msg.timestamp end)}, state}
    else
      {:reply, {:error, :unauthorized}, state}
    end
  end

  @doc """
  Handles the `:send_message` call. Adds a new message to the chat room if the sender is a participant.

  ## Parameters

    - `message`: A tuple `{:send_message, %Message{sender_id: user_id, content: content}}`.
    - `_from`: The GenServer `from` argument.
    - `state`: The current state of the GenServer (`%Chat{}`).

  ## Returns

    - `{:reply, :ok, new_state}`: If the message is successfully added.
    - `{:reply, {:error, :unauthorized}, new_state}`: If the `sender_id` is not a participant.
  """
  @impl true
  def handle_call(
        {:send_message, incoming_message = %Message{sender_id: user_id, content: _content}},
        _from,
        state
      ) do
    if user_id in state.participants do
      msg = %Message{
        incoming_message
        | message_id: UUID.uuid1(),
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

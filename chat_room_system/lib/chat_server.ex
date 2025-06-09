defmodule ChatServer do
  @moduledoc """
  Supervisor to dynamically create chat rooms
  """
  use Supervisor

  @doc "Starts the top-level ChatServer supervisor."
  def start_link(_arg) do
    IO.puts("Chat server starting...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc "Initializes the DynamicSupervisor for chat rooms."
  def init(_init_arg) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: :dynamic_chat_supervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Create a new chat room with the given atom name.

  ## Parameters
  - `name`: The atom name of the room

  ## Returns
  - `{:ok, pid}` or `{:error, reason}`.
  """
  def create_chat_room(name) when is_atom(name) do
    spec = ChatRoom.child_spec(name)
    IO.inspect(spec)
    DynamicSupervisor.start_child(:dynamic_chat_supervisor, spec)
  end

  @doc "Returns a list of currently active chat room names."
  def list_available_rooms() do
    DynamicSupervisor.which_children(:dynamic_chat_supervisor)
    |> Enum.map(fn {id, _pid, _type, _modules} -> id end)
  end
end

defmodule ChatRoomSystem.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      # Start the DynamicSupervisor for chat rooms
      {Registry, keys: :unique, name: :chat_room_registry},
      {DynamicSupervisor, strategy: :one_for_one, name: :dynamic_chat_supervisor}
    ]

    opts = [strategy: :one_for_one, name: ChatRoomSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

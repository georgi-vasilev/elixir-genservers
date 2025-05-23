defmodule ClientChat do
  @moduledoc """
  Wrapper module fro calling ChatRoom functions via :rpc
  """

  @server_node :chat_server@CMP202208S11352

  def join(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :join, [room, user_id])
  end

  def leave(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :leave, [room, user_id])
  end

  def send(room, user_id, content) do
    message = %Message{message_id: UUID.uuid1(), sender_id: user_id, content: content, timestamp: DateTime.utc_now()}
    :rpc.call(@server_node, ChatRoom, :send_message, [room, message])
  end

  def history(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :get_message_history, [room, user_id])
  end
end

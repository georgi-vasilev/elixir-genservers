defmodule ClientChat do
  @moduledoc """
  Wrapper module fro calling ChatRoom functions via :rpc
  """

  @server_node :chat_server@CMP202208S11352

  @doc """
  rpc call to @server_node to join in the chat room
  ## Parameters
  - `room`: the atom name of the room
  - `user_id`: user atom name/id
  """
  def join(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :join, [room, user_id])
  end

  @doc """
  rpc call to @server_node to leave the chat room
  ## Parameters
  - `room`: the atom name of the room
  - `user_id`: user atom name/id
  """
  def leave(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :leave, [room, user_id])
  end

  @doc """
  rpc call to @server_node to send message in the chat room
  ## Parameters
  - `room`: the atom name of the room
  - `user_id`: user atom name/id
  - `content`: the message content
  """
  def send(room, user_id, content) do
    message = %Message{
      sender_id: user_id,
      content: content,
    }

    :rpc.call(@server_node, ChatRoom, :send_message, [room, message])
  end

  @doc """
  rpc call to @server_node to get message history in the given chat room
  ## Parameters
  - `room`: the atom name of the room
  - `user_id`: user atom name/id
  """
  def history(room, user_id) do
    :rpc.call(@server_node, ChatRoom, :get_message_history, [room, user_id])
  end
end

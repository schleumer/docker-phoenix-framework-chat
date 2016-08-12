defmodule Hellow.UserSocket do
  use Phoenix.Socket

  channel "rooms:*", Hellow.RoomChannel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"user_id" => user}, socket) do
    {:ok, assign(socket, :user_id, user)}
  end

  def id(socket) do
    "user:#{socket.assigns[:user_id]}"
  end
end
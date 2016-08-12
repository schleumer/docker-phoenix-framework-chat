defmodule Hellow.RoomChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("rooms:lobby", message, socket) do
    Process.flag(:trap_exit, true)

    send(self, {:after_join, message})

    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def handle_info(any, socket) do
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{
      user: msg["user"],
      body: msg["body"],
      me: socket.assigns.user_id
    }

#    case msg["user"] do
#      "" -> push socket, "new:msg", %{user: "SYSTEM", body: "Username is required"}
#      nil -> push socket, "new:msg", %{user: "SYSTEM", body: "Username is required"}
#      _ -> broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
#    end

    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

#  intercept ["new:msg"]
#
#  def handle_out("new:msg", msg = %{"only": user_id, "me": me}, socket) do
#    IO.inspect msg
#
#    if user_id == socket.assigns.user_id or socket.assigns.user_id == me do
#      push socket, "new:msg", msg
#    end
#
#    {:noreply, socket}
#  end
#
#  def handle_out(any, msg, socket) do
#    push socket, "new:msg", msg
#    {:noreply, socket}
#  end
end
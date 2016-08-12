defmodule Hellow.TcpRoom do
  def connect(username, server) do
    spawn(Hellow.TcpRoom, :init, [username, server])
  end

  def init(username, server) do
    send server, {self, :connect, username}
    loop(username, server)
  end

  def loop(username, server) do
    receive do
      {:info, msg} ->
        IO.puts(~s{[#{username}'s client] - #{msg}})
        loop(username, server)
      {:new_msg, from, msg} ->
        IO.puts(~s{[#{username}'s client] - #{from}: #{msg}})
        loop(username, server)
      {:send, msg} ->
        send server, {self, :broadcast, msg}
        loop(username, server)
      :disconnect ->
        exit(0)
    end
  end

#  use GenServer
#
#  defmodule State do
#     defstruct sock: nil, parent_sock: nil
#  end
#
#  def start_link([sock, parent_sock]) do
#    IO.puts "OK"
#    recv(%State{sock: sock, parent_sock: parent_sock})
#  end
#
#  #def start([sock, parent_sock]) do
#  #  recv(%State{sock: sock, parent_sock: parent_sock})
#  #end
#
#  def recv(state) do
#    case :gen_tcp.recv(state.sock, 0) do
#      {:ok, data} ->
#        IO.inspect data
#        Hellow.TcpChannel.broadcast data
#        recv(state)
#      {:error, _ } ->
#        :gen_tcp.close(state.sock)
#        Process.exit(self(), :exit)
#    end
#  end
#
#  def handle_cast(any, state) do
#    IO.inspect [any, state]
#    { :noreply, state }
#  end
#
#  def handle_info(any, state) do
#    IO.inspect [any, state]
#    { :noreply, state }
#  end
end
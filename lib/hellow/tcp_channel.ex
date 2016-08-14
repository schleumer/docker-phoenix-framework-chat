defmodule Hellow.TcpChannel do
    defmodule Client do
      defstruct sock: nil, nick: nil
    end

    def init do
        {:ok, socket} = :gen_tcp.listen(6666, [:binary, packet: :line, active: false, reuseaddr: true])
        b_pid = spawn fn -> broadcaster_loop [] end
        acceptor_loop(b_pid, socket)
    end

    def acceptor_loop(b_pid, socket) do
        {:ok, client_socket} = :gen_tcp.accept socket
        spawn fn -> client_new b_pid, client_socket end
        acceptor_loop(b_pid, socket)
    end

    def send_all(clients, %{client: client, msg: msg}) do
      send_to_ws "new:msg", client.nick, msg

      clients
      |> not_me(client)
      |> send_all("> #{client.nick}: #{msg}\r\n")
    end

    def send_all(clients, msg) do
        Enum.each clients, fn c ->
          :gen_tcp.send c.sock, msg
        end
    end

    def handle_new_client(clients, client) do
        online = clients
        |> Enum.map(fn c -> c.nick end)
        |> Enum.join(", ")

        send_to_ws "user:entered", client.nick, nil

        send_all clients, "> #{client.nick} has joined [#{online}]\r\n"
    end

    def handle_client_kicked(clients, client) do
        online = clients
        |> Enum.map(fn c -> c.nick end)
        |> Enum.join(", ")

        send_all clients, "> #{client.nick} has left [#{online}]\r\n"
    end

    def broadcaster_loop(clients) do
        receive do
            {:kick, client} ->
              clients = Enum.filter(clients, fn c ->
                                        c != client
                                      end)
              handle_client_kicked clients, client
              broadcaster_loop clients
            {:new_client, client = %Client{}} ->
                clients = [client] ++ clients
                handle_new_client clients, client
                broadcaster_loop clients
            {:new_message, pack}   ->
                send_all clients, pack
                broadcaster_loop clients
        end
    end

    def client_loop(b_pid, socket, client) do
        case :gen_tcp.recv socket, 0 do
          {:ok, msg} ->
            :gen_tcp.send socket, "> #{client.nick}: #{msg}\r\n"
            send b_pid, {:new_message, %{client: client, msg: msg}}
            client_loop b_pid, socket, client
          {:error, _} ->
            send b_pid, {:kick, client}
        end
    end

    def nick_is_valid(nick) do
        nick != ""
    end

    def client_new(b_pid, socket) do
        :gen_tcp.send socket, "Enter your username: "
        {:ok, nick} = :gen_tcp.recv socket, 0
        nick = String.strip nick

        case nick_is_valid(nick) do
            true ->
                :gen_tcp.send socket, "Welcome, just type and press [enter] to send.\r\nKeep in mind that telnet is really limited.\r\nMaybe there will be a port to SSH too\r\n"

                me = %Client{sock: socket, nick: nick}
                send b_pid, {:new_client, me}
                client_loop b_pid, socket, me
            false -> client_new b_pid, socket
        end
    end

    defp not_me(clients, me) do
      Enum.filter clients, fn c ->
        c != me
      end
    end

    defp send_to_ws(event, nick, msg) do
      Hellow.WebsocketEndpoint.broadcast "rooms:lobby", event, %{
        user: nick,
        body: msg,
        me: nick
      }
    end
end

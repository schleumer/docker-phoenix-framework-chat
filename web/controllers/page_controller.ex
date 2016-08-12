defmodule Hellow.PageController do
  use Hellow.Web, :controller

  def index(conn, _params) do
    conn = case get_session(conn, :user_id) do
      nil -> put_session(conn, :user_id, random_string(64))
      _ -> conn
    end

    user_id = get_session(conn, :user_id)

    render conn, "index.html", user_id: user_id
  end

  def send_via_ajax(conn, _params) do
    Hellow.WebsocketEndpoint.broadcast "rooms:lobby", "new:msg", %{
      user: "WEB",
      body: "I CAN DO THIS ALL DAY",
      me: "WEB"
    }

    text conn, "Ok"
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end

defmodule Hellow.WebsocketEndpoint do
  use Phoenix.Endpoint, otp_app: :hellow

  socket "/socket", Hellow.UserSocket

  plug Hellow.Router
end

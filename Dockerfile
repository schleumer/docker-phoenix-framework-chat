FROM trenpixster/elixir:1.3.0

# Compile app
RUN mkdir /app
WORKDIR /app

# Install Elixir Deps
ADD mix.* ./
RUN MIX_ENV=prod mix local.rebar
RUN MIX_ENV=prod mix local.hex --force
RUN MIX_ENV=prod mix deps.get

# Install app
ADD . .
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix phoenix.digest

EXPOSE 4000 8181 6666

CMD PORT=4000 MIX_ENV=prod mix phoenix.server

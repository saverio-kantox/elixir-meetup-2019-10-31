FROM elixir

RUN mix local.hex && mix local.rebar
RUN apt-get update
RUN apt-get install -y inotify-tools
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs
# RUN ln -s /usr/bin/nodejs /usr/bin/node

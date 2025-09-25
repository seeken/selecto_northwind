# syntax=docker/dockerfile:1
FROM hexpm/elixir:1.16.2-erlang-26.2.4-ubuntu-jammy-20240402.1

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    build-essential \
    inotify-tools \
    git \
    curl \
    wget \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install latest PostgreSQL
RUN echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-client-16 && \
    rm -rf /var/lib/apt/lists/*

# Set default user
ARG USERNAME=vscode
RUN useradd -m $USERNAME
USER $USERNAME
WORKDIR /workspaces/selecto_northwind

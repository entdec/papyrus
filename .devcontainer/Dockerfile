FROM ghcr.io/rails/devcontainer/images/ruby:4.0.5

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends imagemagick \
	&& rm -rf /var/lib/apt/lists/*

USER vscode

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

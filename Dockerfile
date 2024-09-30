FROM jetpackio/devbox:latest

# Set /code as the working directory for subsequent commands
WORKDIR /code

# Subsequent commands are run as root
USER root:root

# Create the code directory and change its ownership to user
RUN mkdir -p /code && chown ${DEVBOX_USER}:${DEVBOX_USER} /code

# Subsequent commands are run as user
USER ${DEVBOX_USER}:${DEVBOX_USER}

# Copy important files to container
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} devbox.json devbox.json
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} devbox.lock devbox.lock
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} requirements.txt /code/requirements.txt
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} namelists /code/namelists

# Download and extract FCM v2021.05.0 from github
ADD --chown=${DEVBOX_USER}:${DEVBOX_USER} https://github.com/metomi/fcm/archive/refs/tags/2021.05.0.tar.gz /code/fcm

# Copy JULES source code
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} jules /code/jules

RUN devbox run -- echo "Installed Packages."

# Run 'devbox shell' when the container is started
CMD ["devbox", "shell"]

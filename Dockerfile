FROM debian:buster-slim
ARG USR="wkr"
ARG UID="1000"
ENV PYENV_ROOT="/home/${USR}/.pyenv"

# Set up user
RUN useradd -m -u $UID $USR

# Install pyenv dependencies
RUN apt-get update && apt-get install -y \
          build-essential \
          libssl-dev \
          zlib1g-dev \
          libbz2-dev \
          libreadline-dev \
          libsqlite3-dev \
          wget \
          curl \
          llvm \
          libncurses5-dev \
          xz-utils \
          tk-dev \
          libffi-dev \
          liblzma-dev \
          python-openssl \ 
          git

# Install tox dependencies
RUN apt-get update && apt-get install -y tox
WORKDIR /app

# User installation
USER ${USR}

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git /home/${USR}/.pyenv
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN ${PYENV_ROOT}/bin/pyenv install 3.5.9
RUN ${PYENV_ROOT}/bin/pyenv install 3.6.11
RUN ${PYENV_ROOT}/bin/pyenv install 3.7.9
RUN ${PYENV_ROOT}/bin/pyenv install 3.8.6

CMD ["tox"]


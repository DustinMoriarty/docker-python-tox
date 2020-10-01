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


# User installation
USER ${USR}

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
RUN ${PYENV_ROOT}/bin/pyenv install 3.5.9
RUN ${PYENV_ROOT}/bin/pyenv install 3.6.11
RUN ${PYENV_ROOT}/bin/pyenv install 3.7.9
RUN ${PYENV_ROOT}/bin/pyenv install 3.8.6
RUN ${PYENV_ROOT}/bin/pyenv global 3.5.9 3.6.11 3.7.9 3.8.6

# Install tox dependencies
FROM debian:buster-slim
ARG USR="wkr"
ARG UID="1000"
ENV PYENV_ROOT="/home/${USR}/.pyenv"

RUN apt-get update && apt-get install -y python3 python3-pip
RUN python3 -m pip install tox
RUN useradd -m -u $UID $USR

# Set up user
USER ${USR}

# Copy pyenv
COPY --from=0 $PYENV_ROOT $PYENV_ROOT
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/${USR}/.bashrc

# Set up app
WORKDIR /app

CMD ["tox"]
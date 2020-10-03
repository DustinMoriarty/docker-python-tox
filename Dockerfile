###############################################################################
# Base image.
###############################################################################
FROM debian:buster-slim as base

# Arguments
ARG PYENV_REPO=https://github.com/pyenv/pyenv.git
ARG PYENV_VIRTUALENV_REPO=https://github.com/pyenv/pyenv-virtualenv.git
ARG USR="wkr"
ARG UID="1000"
ARG PYTHON_VERSIONS="3.8.6 3.7.9 3.6.11 3.5.9 2.7.18"

# Environment
ENV PYENV_ROOT="/home/${USR}/.pyenv"
ENV PATH="${PYENV_ROOT}/plugins/pyenv-virtualenv/shims:${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH"

# Set Up User
RUN useradd -m -u $UID $USR

###############################################################################
# Builder image for building python versions.
###############################################################################
FROM base as builder

# Arguments
ARG PYENV_REPO=https://github.com/pyenv/pyenv.git
ARG PYENV_VIRTUALENV_REPO=https://github.com/pyenv/pyenv-virtualenv.git
ARG USR="wkr"
ARG UID="1000"
ARG PYTHON_VERSIONS="3.8.6 3.7.9 3.6.11 3.5.9 2.7.18"

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

# Install pyenv
RUN git clone ${PYENV_REPO} ${PYENV_ROOT}
RUN git clone ${PYENV_VIRTUALENV_REPO} ${PYENV_ROOT}/plugins/pyenv-virtualenv
RUN for VERSION in ${PYTHON_VERSIONS}; \
    do \
        ${PYENV_ROOT}/bin/pyenv install $VERSION ; \
    done;

###############################################################################
# Runtime image without build packages.
###############################################################################
FROM base
ARG USR="wkr"
ARG UID="1000"
ARG PYTHON_VERSIONS="3.8.6 3.7.9 3.6.11 3.5.9 2.7.18"

# Install tox
RUN apt-get update && apt-get install -y python3 python3-pip
RUN python3 -m pip install tox

# Set up app
WORKDIR /app
RUN chmod 777 /app

# Copy pyenv
COPY --from=builder --chown=${USR} $PYENV_ROOT $PYENV_ROOT

ENV PYENV_INIT="eval \"\$(pyenv init -)\" && eval \"\$(pyenv virtualenv-init -)\" && pyenv global ${PYTHON_VERSIONS}" 
# Set up user
USER ${USR}

# Initialize pyenv for bash and sh
RUN echo ${PYENV_INIT} >> /home/${USR}/.bashrc
RUN echo ${PYENV_INIT} >> /home/${USR}/.profile

# Test The Image (Make sure it can test an app with tox.)
COPY --chown=${USR} tests /tests
RUN chmod 777 /tests/test
RUN bash -c "${PYENV_INIT} && /tests/test"

# Run tox in full verbose mode so that all output goes to stderr where 
# it can be accessed in docker logs.
CMD ["tox", "-vv"]

FROM debian:buster-slim
ARG PYENV_REPO=https://github.com/pyenv/pyenv.git
ARG PYENV_VIRTUALENV_REPO=https://github.com/pyenv/pyenv-virtualenv.git
ARG PYTHON_VERSIONS="3.8.6 3.7.9 3.6.11 3.5.9"
ENV PYENV_ROOT="/usr/local/bin/pyenv"

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
# TODO: Switch from .pyenv to pyenv.
RUN git clone ${PYENV_REPO} ${PYENV_ROOT}
RUN git clone ${PYENV_VIRTUALENV_REPO} ${PYENV_ROOT}/plugins/pyenv-virtualenv
RUN for VERSION in ${PYTHON_VERSIONS}; \
    do \
        if ! [[ ${PYENV_ROOT}/bin/pyenv versions ~= $VERSION]]; then \
            ${PYENV_ROOT}/bin/pyenv install $VERSION \
        else;  \
            echo "version $VERSION already installed" \ 
        fi; \
    done;

# Install tox dependencies
FROM debian:buster-slim
ARG USR="wkr"
ARG UID="1000"
ENV PYENV_ROOT="/usr/local/bin/pyenv"
ARG PYTHON_VERSIONS

RUN apt-get update && apt-get install -y python3 python3-pip
RUN python3 -m pip install tox
RUN useradd -m -u $UID $USR

# Set up app
WORKDIR /app
RUN chmod 777 /app

# Copy pyenv
COPY --from=0 --chown=${USR} $PYENV_ROOT $PYENV_ROOT
ENV PATH="${PYENV_ROOT}/plugins/pyenv-virtualenv/shims:${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH"
RUN ${PYENV_ROOT}/bin/pyenv global ${PYENV_VERSIONS}

# Set up user
USER ${USR}
ENV PYENV_INIT='eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)" && echo "pyenv setup"'

# For convenience only when working in the container as shell.
RUN echo ${PYENV_INIT} >> /home/${USR}/.bashrc
RUN echo ${PYENV_INIT} >> /home/${USR}/.profile

COPY --chown=${USR} tests /tests
RUN chmod 777 /tests/test
#RUN /tests/test
#
## Run tox in full verbose mode so that all output goes to stderr where 
## it can be accessed in docker logs.
CMD ["tox", "-vv"]

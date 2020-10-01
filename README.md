# docker-python-tox
Test python projects in a repeatable build environment using tox. This image is to be used as part of a CICD pipeline to test python projects. This image can also be used for local testing in order to avoid the complexity of setting up the pyenv, tox stack and macking sure that tox is being called by the correct python executable.

## Installation
```bash
docker pull buildright/tox
```

## Usage
The application, along with the tox.ini should be placed in the /app directory at runtime.

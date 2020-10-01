# docker-python-tox
Test python projects in a repeatable build environment using tox. This image is to be used as part of a CICD pipeline to test python projects. This image can also be used for local testing in order to avoid the complexity of setting up the pyenv, tox stack and macking sure that tox is being called by the correct python executable.

# Built in Python Versions
The following versions are built in.

* 3.5.9
* 3.6.11
* 3.7.9
* 3.8.6

In order to minimize the size of the image, the pyenv build  requirements are not included. If you would like to use additional versions of python in your own docker image, you will need to also install the necessary build requirements. 


## Installation
Install from docker hub.
```bash
docker pull buildright/tox
```

## Usage
The application, along with the tox.ini should be placed in the /app directory at runtime. In the example below, the path to the application is the present working directory.

```bash
docker run -v "$PWD:/app" buildright/tox
```

#!/bin/bash

# Build the Docker image
docker build -f Dockerfile_tests -t sapi-test .

# Run the tests in a Docker container
docker run --rm sapi-test

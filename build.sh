#!/bin/bash

RB_VERSION="2.0.5"
DOCKER_TAG="reviewboard"

docker build --pull --build-arg "RB_VERSION=${RB_VERSION}" -t "${DOCKER_TAG}:${RB_VERSION}" .

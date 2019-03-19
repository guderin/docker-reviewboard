#!/bin/bash

RB_VERSION="3.0.13"
DOCKER_TAG="reviewboard"

docker build --pull --build-arg "RB_VERSION=${RB_VERSION}" -t "${DOCKER_TAG}:${RB_VERSION}" .

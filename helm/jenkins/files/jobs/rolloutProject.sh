#!/bin/bash

BINDIR=$(dirname $0)
source $BINDIR/_install.sh

errx() {
  echo "$1"
  exit 1
}

_init_() {
  set +x
  [ -z "$PROJECT_NAME" ] && errx "PROJECT_NAME env variable not defined"
  [ -z "$NAMESPACE" ] && NAMESPACE=default
  [ -z "$CLUSTER" ] && errx "CLUSTER environment variable not set (example: prod/nonprod)"
  export NAMESPACE
  export TIMEOUT=300
}

rollout() {
  RUNNING_CYCLES=5 DELAY=15 helm/jenkins/files/jobs/rollout.sh
}

set -e
install_deps
_init_
rollout

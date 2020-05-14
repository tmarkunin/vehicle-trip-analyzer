#!/bin/bash

help() {
  echo "PROJECT_NAME=jenkins CLUSTER=nonprod NAMESPACE=default RELEASE=jenkins APP_VERSION=1.0.0 TEMPLATE=<CLUSTER>.yaml.j2 $0"
}

errx() {
  echo "$1"
  exit 1
}

errargx() {
  help
  errx "$1"
}

pgen() {
  echo -n $(cat /dev/urandom | tr -dc a-zA-Z0-9 | fold -w 32 | head -n 1)
}

conf() {
  RELEASE_DIR=$(pwd)
  DIR=$(dirname $0)
  cd $DIR
  BINDIR=$(pwd)
  [ -z "$PROJECT_NAME" ] && errargx "PROJECT_NAME not defined"
  [ -z "$RELEASE" ] && RELEASE=$PROJECT_NAME
  cd $RELEASE_DIR || errx "Can not cd to RELEASE_DIR: $RELEASE_DIR"
  [ -z "$CLUSTER" ] && errargx "CLUSTER environment variable not set (example: prod/nonprod)"
  [ -z "$NAMESPACE" ] && NAMESPACE=default
  NAMESUFFIX=''
  [ "$NAMESPACE" != "default" ] && NAMESUFFIX="-$NAMESPACE"
  RELEASE=${RELEASE}${NAMESUFFIX}
  INSTALL=0
  if [ -z "$TEMPLATE" ]; then
    TEMPLATE=${CLUSTER}${NAMESUFFIX}.yaml.j2
    [ ! -f $TEMPLATE ] && TEMPLATE=${CLUSTER}${NAMESUFFIX}.yaml
  fi

  [ ! -f $TEMPLATE ] && errx "No template $TEMPLATE for CLUSTER=$CLUSTER NAMESPACE=$NAMESPACE"
  TMPEXT=$(pgen).tmp
  TEMPLATE_TMPFILE=$TEMPLATE.$TMPEXT
}

rollout() {
  if [ -f requirements.yaml ]; then
    helm dependency update 1>/dev/null
  fi

  OLDRELEASE=$(helm ls $RELEASE|grep -v NAME|awk '{print $1}')
  #RELEASE=$(helm ls $RELEASE|grep -v NAME|sed 's/.*DEPLOYED//g'|awk '{print $1}')
  action="upgrade $RELEASE ."
  setvalues=""
  [ ! -z "$APP_VERSION" ] && setvalues="--set image.tag=$APP_VERSION"
  if [ -z "$RELEASE" ]; then
    action="install --name $RELEASE ."
    INSTALL=1
  fi
  j2 --customize $BINDIR/j2-custom.py $TEMPLATE > $TEMPLATE_TMPFILE
  helm $action -f $TEMPLATE_TMPFILE --namespace $NAMESPACE $setvalues
}

rollback() {
  set +e
  perl -I$BINDIR/kubeutils $BINDIR/kubeutils/ContainerStatus.pl
  res=$?
  [ $res -eq 0 ] && return
  if [ $res -eq 1 -a $INSTALL -eq 0 ]; then
    echo "Rollback to $OLDRELEASE"
    helm rollback $OLDRELEASE 0
  fi
}

clean() {
  rm -f $TEMPLATE_TMPFILE
}

conf
set -e
rollout
rollback
clean

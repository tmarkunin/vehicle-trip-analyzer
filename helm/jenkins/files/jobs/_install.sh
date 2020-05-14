#!/bin/sh

_clean_install() {
  cd $DIR
  rm -rf tmp
}

_init_install() {
  export TERRAFORM_VERSION=0.12.25
  export HELM_VERSION=2.13.1
  DIR=$(pwd)
  export PATH=$PATH:/usr/local/bin
  _clean_install
  mkdir -p $DIR/bin tmp
  cd tmp
}

terraform_install() {
  if [ -f /usr/local/bin/terraform ]; then
    terraform -v
    return
  fi
  echo "Install terraform"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 2>&1 1>/dev/null
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  mv terraform /usr/local/bin
  terraform -v
}

kubectl_install() {
  if [ -f /usr/local/bin/kubectl ]; then
    kubectl version
    return
  fi
  echo "Install kubectl"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 2>&1 1>/dev/null
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin
  kubectl version
}

helm_install() {
  if [ -f /usr/local/bin/helm ]; then
    helm version
    return
  fi
  echo "Install helm"
  wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz 2>&1 1>/dev/null
  tar zxf helm-v${HELM_VERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin
  helm init
  helm version
}

install_deps() {
  _init_install
  ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  AptInstallList='curl openssl'
  Pip3InstallList=''
  j2 -v 2>&1 1>/dev/null|| { Pip3InstallList='j2cli'; AptInstallList=${AptInstallList}' python3-pip'; }
  jq --help 2>&1 1>/dev/null|| AptInstallList=${AptInstallList}' jq'
  perl -v 2>&1 1>/dev/null|| AptInstallList=${AptInstallList}' perl'
  apt-get update 2>&1 1>/dev/null
  apt install -y $AptInstallList
  [ "$Pip3InstallList" != '' ] && pip3 install $Pip3InstallList
  terraform_install
  kubectl_install
  helm_install
  _clean_install
}

#!/usr/bin/env bash
#
# This script helps installing the following tools:
#
# - terraform
# - kops
# - kubectl
# - helm
#
# Supports mac and linux.
#
# Usage:
#
# Install all:
#   $ ./install-cli-tools.sh
#
# Install select tools:
#   $ ./install-cli-tools.sh [toolname ...]
#
# Examples:
#
#   $ ./install-cli-tools.sh kubectl terraform
#   $ HELM_VERSION=2.4.1 ./install-cli-tools.sh kubectl helm

set -eo pipefail

KOPS_VERSION="${KOPS_VERSION:-"1.5.3"}"
KUBECTL_VERSION="${KUBECTL_VERSION:-"1.6.1"}"
TERRAFORM_VERSION="${TERRAFORM_VERSION:-"0.9.3"}"
HELM_VERSION="${HELM_VERSION:-"2.4.1"}"

INSTALL_PREFIX="${INSTALL_PREFIX:-"/usr/local/bin"}"

function initOS() {
  OS=$(uname | tr '[:upper:]' '[:lower:]')
}

function install_kops() {
  local version
  local installed_version
  version="$1"
  installed_version=$(kops version 2> /dev/null | cut -d" " -f 2 || echo "")
  if [[ $installed_version = "$version" ]]; then
    echo "kops v${version} is already installed"
    return 0
  fi
  echo "Downloading kops v${version}"
  cd /tmp
  wget --quiet -O kops "https://github.com/kubernetes/kops/releases/download/${version}/kops-${OS}-amd64"
  chmod +x kops
  mv kops "${INSTALL_PREFIX}/kops"
  echo "Installed kops v${version}"
}

function install_kubectl() {
  local version
  local installed_version
  version="$1"
  installed_version=$(kubectl version --client --short 2> /dev/null | cut -d" " -f 3 || echo "")
  if [[ $installed_version = "v$version" ]]; then
    echo "kubectl v${version} is already installed"
    return 0
  fi
  echo "Downloading kubectl v${version}"
  cd /tmp
  wget --quiet -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${version}/bin/${OS}/amd64/kubectl"
  chmod +x kubectl
  mv kubectl "${INSTALL_PREFIX}/kubectl"
  echo "Installed kubectl v${version}"
}

function install_terraform() {
  local version
  local installed_version
  version="$1"
  installed_version=$(terraform version 2> /dev/null | head -n 1 | cut -d" " -f 2 || echo "")
  if [[ $installed_version = "v$version" ]]; then
    echo "terraform v${version} is already installed"
    return 0
  fi
  echo "Downloading terraform v${version}"
  cd /tmp
  wget --quiet -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${version}_${OS}_amd64.zip"
  unzip terraform.zip
  mv terraform "${INSTALL_PREFIX}/terraform"
  echo "Installed terraform v${version}"
}

function install_helm() {
  local version
  local installed_version
  version="$1"
  installed_version=$(helm version --client --short 2> /dev/null | cut -d" " -f 2 | cut -d"+" -f 1 || echo "")
  if [[ $installed_version = "v$version" ]]; then
    echo "helm v${version} is already installed"
    return 0
  fi
  echo "Downloading helm v${version}"
  cd /tmp
  wget --quiet -O helm.tar.gz "https://storage.googleapis.com/kubernetes-helm/helm-v${version}-${OS}-amd64.tar.gz"
  tar xzf helm.tar.gz
  mv "${OS}-amd64/helm" "${INSTALL_PREFIX}/helm"
  echo "Installed helm v${version}"
}

all_pkgs=("kops" "kubectl" "terraform" "helm")

function install() {
  pkgs=("$@")
  # default to all packages if no argument passed
  pkgs=("${pkgs[@]:-${all_pkgs[@]}}")
  for pkg in "${pkgs[@]}"; do
    local version_var
    version_var="$(echo "$pkg" | tr '[:lower:]' '[:upper:]')_VERSION"
    "install_${pkg}" "${!version_var}" &
  done
  # Wait for all background jobs and if one of them fails, exit early
  # with its exit code
  while true; do
    wait -n || {
      code="$?"
      ([[ $code = "127" ]] && exit 0 || exit "$code")
      break
    }
  done;
}

clean() {
  # kill background jobs
  local pids
  pids=($(jobs -p))
  kill "${pids[@]}" 2> /dev/null || true
}

trap 'clean' EXIT

initOS
install "$@"
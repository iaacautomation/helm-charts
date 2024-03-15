#!/bin/bash -x 
set -euo pipefail

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- charts | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
KUBEVAL_VERSION="v0.6.4"
SCHEMA_LOCATION="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/"${KUBEVAL_VERSION}"/kubeconform-linux-amd64.tar.gz
tar -xf /tmp/kubeconform.tar.gz kubeconform

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  helm template "${CHART_DIR}" | ./kubeconform --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done
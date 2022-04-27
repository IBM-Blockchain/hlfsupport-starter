#!/usr/bin/env bash
set -exuo pipefail

# This is a general version playbook generation script
# for targetting both IKS, and OCP

: ${DOCKER_USERNAME:=iamapikey}
: ${DOCKER_EMAIL}
: ${DOCKER_PW}
: ${CLUSTER_TYPE}
: ${PROJECT_NAME_VALUE:=marvin}

CONSOLE_DOMAIN=${CLUSTER_INGRESS_HOSTNAME}
ARCHITECTURE=amd64

if [ $CLUSTER_TYPE == "iks" ]; then
  TARGET_VALUE=k8s
  PROJECT_OR_NAMEPSACE_KEY=namespace
  : ${CONSOLE_STORAGE_CLASS:="default"}
elif [ $CLUSTER_TYPE == "ocp" ]; then
  TARGET_VALUE=openshift
  PROJECT_OR_NAMEPSACE_KEY=project
  : ${CONSOLE_STORAGE_CLASS="default"}
elif [ $CLUSTER_TYPE == "ocp-fyre" ]; then
  TARGET_VALUE=openshift
  PROJECT_OR_NAMEPSACE_KEY=project
  : ${CONSOLE_STORAGE_CLASS:="rook-cephfs"}
else
  echo "CLUSTER_TYPE Unkown, can't create playbooks"
  exit -1
fi

echo "Writing latest-crds.yml file"
cat > latest-crds.yml <<EOF
---
- name: Deploy IBM Blockchain Platform custom resource definitions
  hosts: localhost
  vars:
    state: present
    target: ${TARGET_VALUE}
    arch: ${ARCHITECTURE}
    ${PROJECT_OR_NAMEPSACE_KEY}: ibpinfra
    image_registry_password: ${DOCKER_PW}
    image_registry_email: ${DOCKER_EMAIL}
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.crds
EOF

echo "Writing latest-console.yml file"
cat > latest-console.yml <<EOF
- name: Deploy IBM Blockchain Platform console
  hosts: localhost
  vars:
    state: present
    target: ${TARGET_VALUE}
    arch: amd64
    ${PROJECT_OR_NAMEPSACE_KEY}: ${PROJECT_NAME_VALUE}
    image_registry_password: ${DOCKER_PW}
    image_registry_email: ${DOCKER_EMAIL}
    console_storage_class: ${CONSOLE_STORAGE_CLASS}
    console_domain: ${CONSOLE_DOMAIN}
    console_email: nobody@ibm.com
    console_default_password: new42day
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.console
EOF

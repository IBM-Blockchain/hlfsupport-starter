#!/usr/bin/env bash
set -exuo pipefail
ROOTDIR=$(cd "$(dirname "$0")/.." && pwd)
# This is a general version playbook generation script
# for targetting both IKS, and OCP

DOCKER_REGISTRY=us.icr.io
DOCKER_REPOSITORY=ibp-temp
: ${DOCKER_USERNAME:=iamapikey}     # iks had this as token??
DOCKER_EMAIL=bmxbcv1@us.ibm.com

: ${CONSOLE_DOMAIN}
PRODUCT_VERSION=${CONSOLE_VERSION:-2.5}
FABRIC_V1_VERSION=${FABRIC_V1:-1.4}
FABRIC_V2_VERSION=${FABRIC_V2:-2.4}
COUCHDB_V2_VERSION=${COUCHDB_V2:-2.3}
COUCHDB_V3_VERSION=${COUCHDB_V3:-3.1}

: ${FABRIC_CA_VERSION:=1.5.3}

ARCHITECTURE=amd64

# Enforce these variables to be set
: ${DOCKER_PW}
: ${CLUSTER_TYPE}
: ${PROJECT_NAME_VALUE:="hlf-network"}

if [[ $CLUSTER_TYPE == "iks" || $CLUSTER_TYPE == "k8s" ]]; then
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

# ensure the version tool has been updated
#npm install --prefix ../../utility/ibp_hlf_versions/

function get_latest_tag {
VER=${2:-${PRODUCT_VERSION}}
docker-ls tags -j  -u ${DOCKER_USERNAME} -p ${DOCKER_PW} -r https://${DOCKER_REGISTRY} "$1" | ${ROOTDIR}/utility/ibp_hlf_versions/docker-tags-parse.js -a amd64 -m "~${VER}"
}

: ${CRDWEBHOOK_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-crdwebhook)}
: ${INIT_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-init)}
: ${ENROLLER_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-enroller)}
: ${OPERATOR_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-operator)}
: ${UTILITIES_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-utilities ${FABRIC_V2_VERSION})}
: ${CONSOLE_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-console)}
: ${COUCHDB_TAG_V2:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-couchdb ${COUCHDB_V2_VERSION})}
: ${COUCHDB_TAG_V3:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-couchdb ${COUCHDB_V3_VERSION})}
: ${DEPLOYER_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-deployer)}
: ${GRPCWEB_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-grpcweb)}
: ${FLUENTD_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-fluentd)}
: ${DIND_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-dind ${FABRIC_V1_VERSION})}
: ${PEER_TAG_V1:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-peer ${FABRIC_V1_VERSION})}
: ${PEER_TAG_V2:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-peer ${FABRIC_V2_VERSION})}
: ${PEER_TAG_V2:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-peer ${FABRIC_V2_VERSION})}
: ${ORDERER_TAG_V1:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-orderer ${FABRIC_V1_VERSION})}
: ${ORDERER_TAG_V2:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-orderer ${FABRIC_V2_VERSION})}
: ${CA_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-ca ${FABRIC_CA_VERSION})}
: ${CCENV_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-ccenv ${FABRIC_V2_VERSION})}
: ${GOENV_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-goenv ${FABRIC_V2_VERSION})}
: ${JAVAENV_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-javaenv ${FABRIC_V2_VERSION})}
: ${NODEENV_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-nodeenv ${FABRIC_V2_VERSION})}
: ${CHAINCODE_LAUNCHER_TAG:=$(get_latest_tag ${DOCKER_REPOSITORY}/ibp-chaincode-launcher ${FABRIC_V2_VERSION})}


# determine the full version to use for the playbooks
FABRIC_V2_FULL_VERSION=$(echo ${JAVAENV_TAG} | cut -d '-' -f1)
FABRIC_V1_FULL_VERSION=$(echo ${ORDERER_TAG_V1} | cut -d '-' -f1)
PRODUCT_FULL_VERSION=$(echo ${INIT_TAG} | cut -d '-' -f1)

echo "Writing latest-crds.yml file"
cat >  $ROOTDIR/playbooks/latest-crds.yml  <<EOF
---
- name: Deploy IBM Blockchain Platform custom resource definitions
  hosts: localhost
  vars:
    state: present
    target: ${TARGET_VALUE}
    arch: ${ARCHITECTURE}
    ${PROJECT_OR_NAMEPSACE_KEY}: ibpinfra
    image_registry: ${DOCKER_REGISTRY}
    image_repository: ${DOCKER_REPOSITORY}
    image_registry_url: ""
    image_registry_username: ${DOCKER_USERNAME}
    image_registry_password: ${DOCKER_PW}
    image_registry_email: ${DOCKER_EMAIL}
    product_version: ${PRODUCT_FULL_VERSION}
    webhook_image: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-crdwebhook
    webhook_tag: ${CRDWEBHOOK_TAG}
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.crds
EOF

echo "Writing latest-console.yml file"
cat >  $ROOTDIR/playbooks/latest-console.yml <<EOF
- name: Deploy IBM Blockchain Platform console
  hosts: localhost
  vars:
    state: present
    target: ${TARGET_VALUE}
    arch: ${ARCHITECTURE}
    ${PROJECT_OR_NAMEPSACE_KEY}: ${PROJECT_NAME_VALUE}
    console_domain: ${CONSOLE_DOMAIN}
    console_email: nobody@ibm.com
    console_default_password: new42day
    console_storage_class: ${CONSOLE_STORAGE_CLASS}
    image_registry: ${DOCKER_REGISTRY}
    image_repository: ${DOCKER_REPOSITORY}
    image_registry_url: ""
    image_registry_username: ${DOCKER_USERNAME}
    image_registry_password: ${DOCKER_PW}
    image_registry_email: ${DOCKER_EMAIL}
    product_version: ${PRODUCT_FULL_VERSION}
    operator_image: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-operator
    operator_tag: ${OPERATOR_TAG}
    console_images:
        configtxlatorImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-utilities
        configtxlatorTag: ${UTILITIES_TAG}
        consoleInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
        consoleInitTag: ${INIT_TAG}
        consoleImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-console
        consoleTag: ${CONSOLE_TAG}
        couchdbImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-couchdb
        couchdbTag: ${COUCHDB_TAG_V2}
        deployerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-deployer
        deployerTag: ${DEPLOYER_TAG}
    console_versions:
      ca:
        ${FABRIC_CA_VERSION}-0:
          default: true
          image:
            caImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-ca
            caTag: ${CA_TAG}
            caInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
            caInitTag: ${INIT_TAG}
            enrollerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-enroller
            enrollerTag: ${ENROLLER_TAG}
          version: ${FABRIC_V2_FULL_VERSION}-0
      orderer:
        ${FABRIC_V1_FULL_VERSION}-0:
          default: true
          image:
            grpcwebImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-grpcweb
            grpcwebTag: ${GRPCWEB_TAG}
            ordererImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-orderer
            ordererTag: ${ORDERER_TAG_V1}
            ordererInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
            ordererInitTag: ${INIT_TAG}
            enrollerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-enroller
            enrollerTag: ${ENROLLER_TAG}
          version: ${FABRIC_V1_FULL_VERSION}-0
        ${FABRIC_V2_FULL_VERSION}-0:
          default: false
          image:
            grpcwebImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-grpcweb
            grpcwebTag: ${GRPCWEB_TAG}
            ordererImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-orderer
            ordererTag: ${ORDERER_TAG_V2}
            ordererInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
            ordererInitTag: ${INIT_TAG}
            enrollerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-enroller
            enrollerTag: ${ENROLLER_TAG}
          version: ${FABRIC_V2_FULL_VERSION}-0
      peer:
        ${FABRIC_V1_FULL_VERSION}-0:
          default: true
          image:
            couchdbImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-couchdb
            couchdbTag: ${COUCHDB_TAG_V2}
            dindImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-dind
            dindTag: ${DIND_TAG}
            fluentdImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-fluentd
            fluentdTag: ${FLUENTD_TAG}
            grpcwebImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-grpcweb
            grpcwebTag: ${GRPCWEB_TAG}
            peerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-peer
            peerTag: ${PEER_TAG_V1}
            peerInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
            peerInitTag: ${INIT_TAG}
            enrollerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-enroller
            enrollerTag: ${ENROLLER_TAG}
          version: ${FABRIC_V1_FULL_VERSION}-0
        ${FABRIC_V2_FULL_VERSION}-0:
          default: false
          image:
            chaincodeLauncherImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-chaincode-launcher
            chaincodeLauncherTag: ${CHAINCODE_LAUNCHER_TAG}
            builderImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-ccenv
            builderTag: ${CCENV_TAG}
            goEnvImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-goenv
            goEnvTag: ${GOENV_TAG}
            javaEnvImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-javaenv
            javaEnvTag: ${JAVAENV_TAG}
            nodeEnvImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-nodeenv
            nodeEnvTag: ${NODEENV_TAG}
            couchdbImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-couchdb
            couchdbTag: ${COUCHDB_TAG_V3}
            grpcwebImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-grpcweb
            grpcwebTag: ${GRPCWEB_TAG}
            peerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-peer
            peerTag: ${PEER_TAG_V2}
            peerInitImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-init
            peerInitTag: ${INIT_TAG}
            enrollerImage: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/ibp-enroller
            enrollerTag: ${ENROLLER_TAG}
          version: ${FABRIC_V2_FULL_VERSION}-0
    wait_timeout: 3600
  roles:
    - ibm.blockchain_platform.console
EOF

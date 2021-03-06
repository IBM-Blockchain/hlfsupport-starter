#!/bin/bash

set -e -u -o pipefail
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
: ${IMAGE_NAME:=ghcr.io/hyperledgendary/hlfsupport-in-a-box:main}

mkdir -p ${ROOTDIR}/_cfg && chmod o+rwx ${ROOTDIR}/_cfg

if [ ! -f cfg.env ]; then
  echo "Please ensure a cfg.env file is present"
  exit 1
fi

# If you want to adjust or develop the scripts used, then adjust the workspace mount point
# Use "-v ${ROOTDIR}:/workspace/" to mount the whole directory

# attach these to the host network so it's easier for networking and map in the kubeconfig location
docker run -it --env-file cfg.env -it --network=host -v ${HOME}/.kube/:/root/.kube/ -v ${ROOTDIR}/_cfg:/workspace/_cfg --entrypoint bash ${IMAGE_NAME}
docker run --env-file cfg.env -it --network=host -v ${HOME}/.kube/:/root/.kube/ -v ${ROOTDIR}/_cfg:/workspace/_cfg ${IMAGE_NAME} network
docker run --env-file cfg.env -it --network=host -v ${HOME}/.kube/:/root/.kube/ -v ${ROOTDIR}/_cfg:/workspace/_cfg ${IMAGE_NAME} contract
docker run --env-file cfg.env -it --network=host -v ${HOME}/.kube/:/root/.kube/ -v ${ROOTDIR}/_cfg:/workspace/_cfg ${IMAGE_NAME} application



echo 
echo -----------------------------------------------------------------------------------------------------
echo
echo "Console is available at this URL = " $(cat _cfg/auth-vars.yml | grep api_endpoint | cut -c 15-)
echo
echo "Username = nobody@ibm.com"
echo "Password = new42day"

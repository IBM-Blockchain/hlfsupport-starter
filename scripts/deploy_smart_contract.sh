#!/usr/bin/env bash
set -ex -u -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# pushd ${ROOT_DIR}/applications/contract-typescript
# npm install
# npm run package
# popd

# will be packaged to 
# /workspace/ibp-fabric-toolchain-demo-scenario/contracts/asset-transfer-ts/asset-transfer-basic.tgz
cd ${ROOT_DIR}/playbooks/fabric-test-network
export IBP_ANSIBLE_LOG_FILENAME=ansible_debug_deploy_contract.log

cat > cc-vars.yml <<EOF
---
smart_contract_name: "asset-transfer"
smart_contract_version: "1.0.0"
smart_contract_sequence: 1
smart_contract_package: $ROOT_DIR/applications/contract-typescript/assettransfer.tgz
EOF

set -x
ansible-playbook 19-install-and-approve-chaincode.yml --extra-vars @auth-vars.yml --extra-vars @cc-vars.yml
ansible-playbook 20-install-and-approve-chaincode.yml --extra-vars @auth-vars.yml --extra-vars @cc-vars.yml
ansible-playbook 21-commit-chaincode.yml --extra-vars @auth-vars.yml --extra-vars @cc-vars.yml
ansible-playbook 22-register-application.yml --extra-vars @auth-vars.yml --extra-vars @cc-vars.yml
ansible-playbook 23-register-application.yml --extra-vars @auth-vars.yml --extra-vars @cc-vars.yml
set +x
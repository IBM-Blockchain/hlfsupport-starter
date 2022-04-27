#
# SPDX-License-Identifier: Apache-2.0
#
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive 

# Build tools
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y --no-install-recommends install curl build-essential gcc gzip \
    python3.8 python3-distutils libpython3.8-dev software-properties-common zip unzip \
    git jq\       
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Kube CLI (and OpenShift wrapper)
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6.0-202005061824.git.1.7376912.el7/linux/oc.tar.gz --output oc.tar.gz \
    && tar xvzf oc.tar.gz \
    && chmod u+x ./oc \
    && mv ./oc /usr/local/bin/oc

RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 

# Docker-ls (for ansible playbook generation)
RUN curl -L https://github.com/mayflower/docker-ls/releases/download/v0.3.2/docker-ls-linux-amd64.zip --output docker-ls.zip \
    && unzip docker-ls.zip \
    && chmod u+x docker-ls \
    && mv docker-ls /usr/local/bin/ \
    && chmod u+x docker-rm \
    && mv docker-rm /usr/local/bin/

# Fabric tooling
RUN mkdir -p /opt/fabric \
    && curl -sSL https://github.com/hyperledger/fabric/releases/download/v2.2.1/hyperledger-fabric-linux-amd64-2.2.1.tar.gz | tar xzf - -C /opt/fabric  \
    && curl -sSL https://github.com/hyperledger/fabric-ca/releases/download/v1.5.3/hyperledger-fabric-ca-linux-amd64-1.5.3.tar.gz | tar xzf - -C /opt/fabric
ENV FABRIC_CFG_PATH=/opt/fabric/config
ENV PATH=/opt/fabric/bin:${PATH}

# Add editor
RUN cd /usr/local/bin; curl https://getmic.ro | bash \
    && curl -sL https://github.com/jt-nti/cds-cli/releases/download/0.3.0/cds-0.3.0-linux > /opt/fabric/bin/cds && chmod +x /opt/fabric/bin/cds

# IBM Cloud CLI
#RUN curl -sL https://raw.githubusercontent.com/IBM-Cloud/ibm-cloud-developer-tools/master/linux-installer/idt-installer | bash
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Python & Ansible
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3.8 get-pip.py  \
    && pip3.8 install  "ansible>=2.9,<2.10" fabric-sdk-py python-pkcs11 openshift semantic_version\
    && ansible --version 


RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Ensure that there is a node installation
RUN mkdir -p  /usr/local/node  \
    && curl -sSL https://nodejs.org/download/release/v16.4.0/node-v16.4.0-linux-x64.tar.xz | tar xJf - -C /usr/local/node --strip-components=1



# Setup a user to run things as
RUN groupadd fabric && useradd -rm -d /home/fabric-user -s /bin/bash -g fabric -g root -G sudo -u 1001 fabric -p "$(openssl passwd -1 fabric)"
RUN mkdir -p /workspace && chown fabric /workspace
USER fabric
ENV PATH="/usr/local/node/bin:${PATH}"


WORKDIR /workspace

# Get the very latest ansible collection
RUN git clone -b main https://github.com/IBM-Blockchain/ansible-collection.git /workspace/ansible-collection \
    && ansible-galaxy collection build /workspace/ansible-collection -f \
    && ansible-galaxy collection install ibm-blockchain_platform-*.tar.gz -f




COPY --chown=fabric scripts /workspace/scripts
COPY --chown=fabric utility /workspace/utility
COPY --chown=fabric playbooks /workspace/playbooks
COPY --chown=fabric justfile /workspace/
RUN  npm --prefix /workspace/utility/ibp_hlf_versions install

# Use entry point, so that other command line args get passed to just directly
ENTRYPOINT ["just"]

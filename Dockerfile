FROM ubuntu:focal

ARG TERRAFORM_VER="1.0.9"
ARG TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip"
ARG PACKER_VER="1.7.6"
ARG PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip"
ARG AWS_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
ARG ANSIBLE_VER="4.7.0"
ARG KUBERNETES_GPG_KEY_URL="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
ARG YQ_VER="4.14.2"
ARG YQ_URL="https://github.com/mikefarah/yq/releases/download/v${YQ_VER}/yq_linux_amd64"
ARG HELM_VER="3.7.1"
ARG HELM_URL="https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz"

LABEL maintainer="brujack"
LABEL terraform_version=$TERRAFORM_VER
LABEL packer_version=$PACKER_VER
LABEL ansible_version=$ANSIBLE_VER

ENV DEBIAN_FRONTEND=noninteractive
ENV AWSCLI_VERSION=${AWSCLI_VER}
ENV TERRAFORM_VERSION=${TERRAFORM_VER}
ENV PACKER_VERSION=${PACKER_VER}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && apt-get update \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y --no-install-recommends apt-utils curl git jq make python3 python3-pip python3-boto tar unzip wget \
    && apt-get upgrade -y \
    && mkdir -p downloads/helm \
    && wget -q -O downloads/terraform_${TERRAFORM_VER}_linux_amd64.zip ${TERRAFORM_URL} \
    && wget -q -O downloads/packer_${PACKER_VER}_linux_amd64.zip ${PACKER_URL} \
    && unzip 'downloads/*.zip' -d /usr/local/bin \
    && wget -q -O downloads/awscliv2.zip ${AWS_URL} \
    && unzip 'downloads/awscliv2.zip' -d downloads \
    && downloads/aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg ${KUBERNETES_GPG_KEY_URL} \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && wget -q -O downloads/yq_${YQ_VER} ${YQ_URL} \
    && cp -a downloads/yq_${YQ_VER} /usr/local/bin \
    && mv /usr/local/bin/yq_${YQ_VER} /usr/local/bin/yq \
    && chmod 755 /usr/local/bin/yq \
    && chown root:root /usr/local/bin/yq \
    && wget -q -O downloads/helm-v${HELM_VER}-linux-amd64.tar.gz ${HELM_URL} \
    && tar -zxvf downloads/helm-v${HELM_VER}-linux-amd64.tar.gz -C downloads/helm \
    && mv downloads/helm/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf downloads \
    && python3 -m pip install --no-cache-dir ansible ansible-lint \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* downloads/*
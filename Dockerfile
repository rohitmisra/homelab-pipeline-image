FROM ubuntu:22.04
ARG TARGETPLATFORM

ENV TERRAFORM_VERSION=1.8.4
ENV ANSIBLE_VERSION=2.9.25
ENV BOTO3_VERSION=1.26.104
ENV BITWARDEN_CLI_VERSION=1.19.1
ENV PYTHONUNBUFFERED=1

ENV TARGETPLATFORM=$TARGETPLATFORM

RUN apt-get update && apt-get install -y \
	curl \
	unzip \
	npm \
	build-essential \
    python3-pip \
    ca-certificates \
    openssh-client \
    jq \
    && apt-get install -y --no-install-recommends \
    python3-dev \
    libffi-dev \
    build-essential \
    && pip3 install --no-cache --upgrade pip setuptools cffi \
    && pip3 install ansible==${ANSIBLE_VERSION} boto3==${BOTO3_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# # Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

# # Install Terraform
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
          TERRAFORM_ARCH=linux_amd64; \
       elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
          TERRAFORM_ARCH=linux_arm64; \
       fi \
    && curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_ARCH}.zip" \
    && unzip "terraform_${TERRAFORM_VERSION}_${TERRAFORM_ARCH}.zip" -d /usr/local/bin \
    && rm "terraform_${TERRAFORM_VERSION}_${TERRAFORM_ARCH}.zip"


# # Install Bitwarden Secrets Manager CLI

RUN cargo install bws

# # Configure Ansible
RUN mkdir -p /etc/ansible \
    && echo 'localhost' > /etc/ansible/hosts

ENTRYPOINT ["sh", "-c", "terraform -v && ansible --version && bws --version && /bin/bash"]

FROM alpine:3.13.6

ENV TERRAFORM_VERSION=0.14.0
ENV ANSIBLE_VERSION=2.9.6
ENV BOTO_VERSION=2.49.0

RUN echo "===> Installing Python..." && \
	apk --update add python \
		py-pip \
		openssl \
		ca-certificates && \
	apk --update add --virtual .build-deps \
		python-dev \
		libffi-dev \
		openssl-dev \
		build-base && \
	pip install --upgrade pip cffi && \
	\
	echo "===> Installing Ansible and Boto Library..." && \
	pip install ansible==${ANSIBLE_VERSION} && \
	pip install boto==${BOTO_VERSION} && \
	\
	apk del .build-deps && \
	rm -rf /var/cache/apk/* && \
	\
	echo "===> Installing OpenSSH Client..." && \
	apk --update add openssh-client wget && \
	\
	echo "===> Adding localhost to hosts file..." && \
	mkdir -p /etc/ansible && \
	echo 'localhost' > /etc/ansible/hosts && \
	\
	echo "===> Installing Terraform..." && \
	wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	\
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
	rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ENTRYPOINT ["sh", "-c", "terraform -v && ansible --version"]
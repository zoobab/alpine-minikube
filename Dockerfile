FROM alpine:3.6
MAINTAINER William Hindes <bhindes@hotmail.com>

ENV GOPATH="/usr/bin"
ENV GOROOT="/usr/lib/go"

RUN apk --update --no-cache add docker sudo bash
RUN apk upgrade --update
RUN apk add --no-cache --virtual=.build-dependencies ca-certificates python2 wget go make \
autoconf findutils make pkgconf libtool g++ automake linux-headers git
RUN  wget "https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl" -O "/usr/local/bin/kubectl"
RUN mkdir -pv /usr/bin/src/k8s.io
RUN cd /usr/bin/src/k8s.io && chmod +x /usr/local/bin/kubectl
RUN cd /usr/bin/src/k8s.io && git clone https://github.com/kubernetes/minikube && cd minikube && \
make && mv ./out/minikube /usr/local/bin/minikube && rm -rf /usr/bin/src/k8s.io && rm -rf /tmp/*
RUN minikube start --vm-driver none --kubernetes-version v1.7.5 -v 7 --memory 1024 --disk-size 4g
RUN apk del .build-dependencies
ADD ./dockerd-entrypoint.sh /usr/local/bin/
ADD ./dockerd-cmd.sh /usr/local/bin/
ADD ./setup-compose /usr/local/bin/


EXPOSE 2375 30000
ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD ["dockerd-cmd.sh"]

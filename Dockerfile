FROM alpine:3.12.4
ENV VERIFY_CHECKSUM=false
# ENV HELM_VERSION=3.5.3
# RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.12.4/main' >> /etc/apk/repositories
ARG HELM_VERSION

RUN apk add --no-cache ca-certificates bash openssl \
    && rm -rf /var/cache/apk/* \
    && echo "Helm Version : ${HELM_VERSION}" \
    && wget --no-check-certificate  https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm
    # && helm repo add "stable" "https://charts.helm.sh/stable"

ENTRYPOINT [ "helm" ]
WORKDIR /workdir
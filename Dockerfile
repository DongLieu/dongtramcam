FROM golang:1.18-alpine3.16 AS go-builder

RUN set -eux

RUN apk add --no-cache ca-certificates git build-base linux-headers

WORKDIR /code
COPY . /code/

# Install dongtramcamd binary
RUN echo "Installing dongtramcamd binary"
RUN make build

#-------------------------------------------
FROM alpine:3.16

RUN apk add --no-cache bash py3-pip jq curl
RUN pip install toml-cli

COPY --from=go-builder /code/bin/dongtramcamd /usr/bin/dongtramcamd

COPY answer/* /opt/
RUN chmod +x /opt/*.sh

WORKDIR /opt

# rest server
EXPOSE 1350
# tendermint rpc
EXPOSE 1711

CMD ["dongtramcamd", "version"]
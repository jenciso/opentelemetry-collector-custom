FROM golang:1.23.3-alpine3.20 as build

ARG OTEL_VERSION=0.114.0
COPY . /build
RUN go install go.opentelemetry.io/collector/cmd/builder@v${OTEL_VERSION}
RUN builder --config=/build/.otelcol-builder.yaml

FROM alpine:3.20.3 as certs

RUN apk --update add ca-certificates
ARG USER_UID=10001
USER ${USER_UID}

FROM golang:1.23.3-alpine3.20 as prod

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /tmp/dist/os-otel-collector /
RUN chmod 755 /os-otel-collector

ENTRYPOINT ["/os-otel-collector"]

EXPOSE 4319 4320 8007

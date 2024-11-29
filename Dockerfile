FROM golang:1.23.3-alpine3.20 AS build
ARG OTEL_VERSION=0.114.0
ADD manifest.yaml /build/
RUN go install go.opentelemetry.io/collector/cmd/builder@v${OTEL_VERSION}
RUN builder --config=/build/manifest.yaml


FROM alpine:3.20.3 AS certs
RUN apk --update add ca-certificates


FROM scratch
ARG USER_UID=10001
USER ${USER_UID}
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build --chmod=755 /tmp/dist/os-otel-collector /os-otel-collector
COPY config.yaml /etc/otelcol-contrib/config.yaml

ENTRYPOINT ["/os-otel-collector"]
CMD ["--config", "/etc/otelcol-contrib/config.yaml"]
EXPOSE 4317 4318 55678 55679

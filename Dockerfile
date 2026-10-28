FROM docker.io/golang:1.27-alpine as builder
ARG CGO_ENABLED=0
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build

FROM scratch
COPY --from=builder /app/rsscombine /rsscombine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/rsscombine"]

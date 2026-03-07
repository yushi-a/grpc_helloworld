FROM golang:1.26 AS builder
WORKDIR /go/src/app/
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN make build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/app/appctl .
CMD ["/root/appctl"]

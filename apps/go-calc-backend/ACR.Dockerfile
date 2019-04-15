ARG appfolder="apps/go-calc-backend/app"

FROM golang:alpine AS builder
ARG appfolder
RUN apk update && apk add --no-cache git
RUN adduser -D -g '' appuser
WORKDIR /go/src/phoenix/go-calc-backend
COPY ${basedir}/ .
RUN go get -d -v
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/go-calc-backend 

FROM alpine:latest as go-calc-backend
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/bin/go-calc-backend /go/bin/go-calc-backend
EXPOSE 8080
USER appuser
ENV NODE_ENV production
ENV BUILD_INFO $build_info
ENTRYPOINT ["/go/bin/go-calc-backend"]
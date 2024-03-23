# This Dockerfile produces two images. The first is the build image, which contains the
# Go compiler, React.js toolchain, and source code for the program. The second is the
# Multistage Image Builds | 23

## STAGE 1: Build
FROM golang:1.17-alpine AS build

# Install Node and NPM
RUN apk update \
    && apk upgrade \
    && apk add --no-cache git nodejs bash npm

# Get dependencies for Go part of build
RUN go get -u github.com/jteeuwen/go-bindata/... \
    && go get github.com/tools/godep

WORKDIR /go/src/github.com/kubernetes-up-and-running/kuard

# Copy all sources in
COPY . .

# This is a set of variables that the build script expects
ENV VERBOSE=0
ENV PKG=github.com/kubernetes-up-and-running/kuard
ENV ARCH=amd64
ENV VERSION=test

# Do the build. Script is part of incoming sources.
RUN build/build.sh

## STAGE 2: Deployment
FROM alpine

USER nobody:nobody

# Copy the executable from the build stage ~ always remember ~from=previous_build_name
COPY --from=build /go/bin/kuard /kuard

CMD [ "/kuard" ]


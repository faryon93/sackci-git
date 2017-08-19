FROM alpine:latest
MAINTAINER Maximilian Pachl <m@ximilian.info>

# install all necessary tools
RUN apk add --update \
	git && \

# remove build dependencies
	rm -rf /var/cache/apk/*

# add the user which will run the build
RUN adduser -D -u 1000 -g 'sackci' sackci

# setup the build environment
ADD setup /usr/bin
RUN mkdir /work && \
    chmod 755 /usr/bin/setup


# container startup behaviour
USER sackci
WORKDIR /work
ENTRYPOINT ["/usr/bin/setup"]

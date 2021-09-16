FROM docker.io/alpine:3.14

RUN apk --update --no-cache add \
		ca-certificates \
		git

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

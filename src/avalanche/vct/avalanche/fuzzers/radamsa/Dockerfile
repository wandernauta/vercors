FROM alpine:3.21
EXPOSE 10070
ADD "https://gitlab.com/-/project/6703375/uploads/d774a42f7893012d0a56c490a75ae12b/radamsa-0.7.c.gz" /

RUN <<EOF
    apk add --no-cache gcc musl-dev busybox-extras
    gunzip radamsa-0.7.c.gz
    cc radamsa-0.7.c -o radamsa
EOF

ADD serve.sh serve.sh
ADD corpus corpus

CMD ["tcpsvd", "-v", "0.0.0.0", "10070", "sh", "serve.sh"]
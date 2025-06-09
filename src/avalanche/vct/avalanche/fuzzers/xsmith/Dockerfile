FROM racket/racket:8.9
RUN raco pkg install --installation --no-docs --no-cache --batch --auto https://gitlab.flux.utah.edu/xsmith/xsmith.git\?path\=xsmith#xsmith-2.0.8
ADD grammar.rkt grammar.rkt
CMD ["racket", "grammar.rkt", "--server", "true", "--server-ip", "false", "--server-port", "10070"]
EXPOSE 10070

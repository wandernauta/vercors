FROM python:3.13-alpine
RUN pip install --no-cache-dir grammarinator
ADD grammars grammars
RUN grammarinator-process grammars/c.g4 && \
    grammarinator-process grammars/cpp.g4 && \
    grammarinator-process grammars/java.g4 && \
    grammarinator-process grammars/llvm.g4 && \
    grammarinator-process grammars/pvl.g4
ADD serve.py serve.py

CMD ["python", "serve.py"]
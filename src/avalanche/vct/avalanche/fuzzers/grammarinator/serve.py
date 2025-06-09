#!/usr/bin/env python3

"""
AValAnCHE-compatible fuzzer integration for Grammarinator-based fuzzers.
"""

import http
import http.server
import random
import sys
import tempfile

from grammarinator.generate import execute


GRAMMARS = ('c', 'cpp', 'java', 'pvl')

class GrammarBased(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        grammar = random.choice(GRAMMARS)

        self.send_response(http.HTTPStatus.OK)
        self.send_header("Content-Type", f"text/x-{grammar}")
        self.end_headers()

        with tempfile.NamedTemporaryFile() as fp:
            sys.argv = ['_', '-d', '15', '-o', fp.name, '--sys-path', '.', f'{grammar}Generator.{grammar}Generator', '--serializer', 'grammarinator.runtime.simple_space_serializer']
            execute()

            with open(fp.name, 'rb') as f:
                self.wfile.write(f.read())


if __name__ == '__main__':
    http.server.ThreadingHTTPServer(('', 10070), GrammarBased).serve_forever()
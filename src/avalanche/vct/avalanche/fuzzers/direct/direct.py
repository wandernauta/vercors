#!/usr/bin/env python3

"""
AValAnCHE-compatible "fuzzer" "integration" that just returns the seed input unmodified.
"""

import base64
import http
import http.server


class Direct(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(http.HTTPStatus.OK)
        self.send_header("Content-Type", "application/octet-stream")
        self.end_headers()
        self.wfile.write(base64.urlsafe_b64decode(self.path.split('?')[1]))


if __name__ == '__main__':
    http.server.ThreadingHTTPServer(('', 10070), Direct).serve_forever()
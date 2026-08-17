#!/usr/bin/env python3
"""Static file server for the QA web build.

`python3 -m http.server` is almost enough, but not quite:

* `.wasm` is not in every Python's mimetypes table, and a wasm file served as
  `application/octet-stream` makes the browser refuse to compile it — drift's
  sqlite3.wasm then fails to load and every screen renders as an error state.
  That would show up to the QA testers as dozens of phantom "app is broken"
  findings rather than the one real cause.
* SPA routing: the Flutter app owns its own routes, so an unknown path must
  serve index.html instead of a 404.

Deliberately NOT setting Cross-Origin-Embedder-Policy. `require-corp` would let
drift use SharedArrayBuffer, but it also blocks the cross-origin Google Fonts
the app fetches at boot, and the design/layout testers would then report a wall
of false typography defects. drift's WasmDatabase.open() degrades to an
IndexedDB-backed implementation without it, which is fine for QA data.

Usage: qa_http_server.py <root-dir> <port>
"""
import mimetypes
import os
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("text/javascript", ".js")
mimetypes.add_type("application/json", ".json")


class QaHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # The tester reloads the same URL constantly; a cached stale bundle
        # would have it assert against code that is no longer deployed.
        self.send_header("Cache-Control", "no-store, max-age=0")
        super().end_headers()

    def send_head(self):
        path = self.translate_path(self.path)
        if not os.path.exists(path) and not self.path.startswith("/assets"):
            self.path = "/index.html"
        return super().send_head()

    def log_message(self, fmt, *args):
        # One line per asset request would bury the harness log.
        pass


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        return 2
    root, port = sys.argv[1], int(sys.argv[2])
    if not os.path.isdir(root):
        print(f"root does not exist: {root}", file=sys.stderr)
        return 1
    handler = partial(QaHandler, directory=root)
    server = ThreadingHTTPServer(("127.0.0.1", port), handler)
    server.daemon_threads = True
    print(f"serving {root} on http://127.0.0.1:{port}", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# ///
"""Generate or decode mermaid.live URLs.

Usage:
    uvx mermaid_url.py encode <file_or_code>
    uvx mermaid_url.py decode <url>

Examples:
    echo 'flowchart TD\n  A --> B' | uvx mermaid_url.py encode -
    uvx mermaid_url.py encode diagram.mmd
    uvx mermaid_url.py encode 'flowchart TD\n  A --> B'
    uvx mermaid_url.py decode 'https://mermaid.live/edit#pako:...'
"""

import base64
import json
import sys
import zlib


def encode(code: str, theme: str = "default") -> str:
    state = json.dumps(
        {
            "code": code,
            "mermaid": json.dumps({"theme": theme}),
            "updateDiagram": True,
        },
        separators=(",", ":"),
    )
    compressed = zlib.compress(state.encode())
    b64 = base64.urlsafe_b64encode(compressed).decode().rstrip("=")
    return f"https://mermaid.live/edit#pako:{b64}"


def decode(url: str) -> str:
    fragment = url.split("#pako:", 1)[1]
    b64 = fragment.replace("-", "+").replace("_", "/")
    b64 += "=" * (4 - len(b64) % 4) if len(b64) % 4 else ""
    raw = base64.b64decode(b64)
    decompressed = zlib.decompress(raw)
    state = json.loads(decompressed)
    return state["code"]


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__.strip())
        sys.exit(0)

    command = sys.argv[1]

    if command == "encode":
        if len(sys.argv) < 3 or sys.argv[2] == "-":
            code = sys.stdin.read()
        elif sys.argv[2].endswith((".mmd", ".mermaid", ".md", ".txt")):
            with open(sys.argv[2]) as f:
                code = f.read()
        else:
            code = sys.argv[2]
        print(encode(code))

    elif command == "decode":
        if len(sys.argv) < 3:
            print("Error: URL argument required", file=sys.stderr)
            sys.exit(1)
        print(decode(sys.argv[2]))

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

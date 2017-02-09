#!/bin/bash
BOTG_SCRIPT_DIR=$(dirname $0)
cmake --build . | \
    tee >($BOTG_SCRIPT_DIR/contrib/ansi2html/ansi2html.sh --bg=dark >botg-build.html)


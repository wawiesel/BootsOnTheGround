#!/bin/bash
BOTG_SCRIPT_DIR=$(dirname $0)
XCOL=$BOTG_SCRIPT_DIR/contrib/xcol/xcolorize.sh
ctest | $XCOL \
        green '^.*   Passed.*$' \
         blue ' *100% tests passed.*' \
          red '^.*\*\*\*Failed.*$' \
          red '^.* [^0] tests failed out of.*' \
| tee >($BOTG_SCRIPT_DIR/contrib/ansi2html/ansi2html.sh --bg=dark >botg-test.html)


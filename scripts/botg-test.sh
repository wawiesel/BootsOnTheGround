#!/bin/bash
XCOL=$(dirname $0)/contrib/xcol/xcolorize.sh
ctest | $XCOL \
        green '^.*   Passed.*$' \
         blue ' *100% tests passed.*' \
          red '^.*\*\*\*Failed.*$' \
          red '^.* [^0] tests failed out of.*'

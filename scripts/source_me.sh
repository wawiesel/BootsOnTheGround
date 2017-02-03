#This script adds the scripts PATH to the environment so that the
#BootsOnTheGround scripts can be used.
called=$_
[[ $called != $0 ]] || echo "source_me.sh must be sourced!" && exit
BOTG_SCRIPT_DIR=$(cd $(dirname $BASH_SOURCE) && pwd)
export PATH=BOTG_SCRIPT_DIR:$PATH

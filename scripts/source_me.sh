#This script adds the scripts PATH to the environment so that the
#BootsOnTheGround scripts can be used.
called=$_
if [[ $called != $0 ]];
then
    BOTG_SCRIPT_DIR=$(cd $(dirname $BASH_SOURCE) && pwd)
    export PATH=$BOTG_SCRIPT_DIR:$PATH
else
    echo "source_me.sh must be sourced!"
fi

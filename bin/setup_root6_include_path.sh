#! /bin/bash
# prepend local variables with local_ so we do not accidentally overwrite
# user variables
unset ROOT_INCLUDE_PATH
export EVT_LIB=$ROOTSYS/lib
ROOT_INCLUDE_PATH=./
local_offline_main_done=0
# make sure our include dirs come first in ROOT_INCLUDE_PATH
# use OFFLINE_MAIN only if it comes in the list of arguments, flag it as used
if [ $# -gt 0 ]
then
  for arg in "$@"
  do
    if [ $arg = "$OFFLINE_MAIN" ]
    then
      local_offline_main_done=1
    fi
    if [ -d $arg ]
    then
      for local_incdir in `find $arg/include -maxdepth 1 -type d -print`
      do
        if [ -d $local_incdir ]
        then
          if [[ $local_incdir != *"CGAL"* && $local_incdir != *"Vc"* && $local_incdir != *"rave"* && $local_incdir != *"gloo"* ]]
          then
            ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$local_incdir
          fi
        fi
      done
    fi
  done
fi 
if [ $local_offline_main_done == 0 ]
then
    ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$OFFLINE_MAIN/include
  for local_incdir in `find $OFFLINE_MAIN/include -maxdepth 1 -type d -print`
  do
    if [ -d $local_incdir ]
    then
      if [[ $local_incdir != *"CGAL"* && $local_incdir != *"Vc"* && $local_incdir != *"rave"* ]]
      then
        ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$local_incdir
      fi
    fi
  done
fi
# add ROOT Macros
if [ -d $OFFLINE_MAIN/rootmacros ]
then
  ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$OFFLINE_MAIN/rootmacros
fi
export ROOT_INCLUDE_PATH
#unset locally used variables
unset local_incdir
unset local_offline_main_done
#echo $ROOT_INCLUDE_PATH

#! /bin/bash
# prepend local variables with local_ so we do not accidentally overwrite
# user variables
unset ROOT_INCLUDE_PATH
export EVT_LIB=$ROOTSYS/lib
local_first=1
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
          if [ $local_first == 1 ]
          then
            ROOT_INCLUDE_PATH=$local_incdir
            local_first=0
          else
            if [[ $local_incdir != *"CGAL"* && $local_incdir != *"Vc"* && $local_incdir != *"rave"* ]]
            then
              ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$local_incdir
            fi
          fi
        fi
      done
    fi
  done
fi 
if [ $local_offline_main_done == 0 ]
then
  if [ $local_first == 1 ]
  then
    ROOT_INCLUDE_PATH=$OFFLINE_MAIN/include
  else
    ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$OFFLINE_MAIN/include
  fi
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
ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$G4_MAIN/include
# add G4 include path
export ROOT_INCLUDE_PATH
#unset locally used variables
unset local_first
unset local_incdir
unset local_offline_main_done
#echo $ROOT_INCLUDE_PATH

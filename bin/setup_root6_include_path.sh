#! /bin/bash
unset ROOT_INCLUDE_PATH
export EVT_LIB=$ROOTSYS/lib
first=1
offline_main_done=0
# make sure our include dirs come first in ROOT_INCLUDE_PATH
# use OFFLINE_MAIN only if it comes in the list of arguments, flag it as used
if [ $# -gt 0 ]
then
  for arg in "$@"
  do
    if [ $arg = "$OFFLINE_MAIN" ]
    then
      offline_main_done=1
    fi
    if [ -d $arg ]
    then
      for incdir in `find $arg/include -maxdepth 1 -type d -print`
      do
        if [ -d $incdir ]
        then
          if [ $first == 1 ]
          then
            ROOT_INCLUDE_PATH=$incdir
            first=0
          else
            if [[ $incdir != *"CGAL"* && $incdir != *"Vc"* && $incdir != *"rave"* ]]
            then
              ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$incdir
            fi
          fi
        fi
      done
    fi
  done
fi 
if [ $offline_main_done == 0 ]
then
  if [ $first == 1 ]
  then
    ROOT_INCLUDE_PATH=$OFFLINE_MAIN/include
  else
    ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$OFFLINE_MAIN/include
  fi
  for incdir in `find $OFFLINE_MAIN/include -maxdepth 1 -type d -print`
  do
    if [ -d $incdir ]
    then
      if [[ $incdir != *"CGAL"* && $incdir != *"Vc"* && $incdir != *"rave"* ]]
      then
        ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$incdir
      fi
    fi
  done
fi
ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$G4_MAIN/include
# add G4 include path
export ROOT_INCLUDE_PATH
#unset locally used variables
unset first
unset offline_main_done
unset incdir
#echo $ROOT_INCLUDE_PATH

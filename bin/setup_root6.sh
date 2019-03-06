#! /bin/bash
unset ROOT_INCLUDE_PATH
export EVT_LIB=$ROOTSYS/lib
first=1
offline_main_done=0
# make sure our include dirs come first in ROOT_INCLUDE_PATH
# use OFFLINE_MAIN only if it comes in the list of arguments, flag it as used
if [ $# > 0 ]
then
  for arg in "$@"
  do
    if [ $arg = "$OFFLINE_MAIN" ]
    then
      offline_main_done=1
      if [ $first == 1 ] 
      then
        root_include_path=$OFFLINE_MAIN/include
        first=0
      else
        root_include_path=$root_include_path:$OFFLINE_MAIN/include
      fi
root_include_path=$root_include_path:$OFFLINE_MAIN/include/eigen3:$OFFLINE_MAIN/include/g4detectors:$OFFLINE_MAIN/include/phhepmc:$OFFLINE_MAIN/include/calobase
    else
      if [ -d $arg ]
      then
        for incdir in `find $arg/include -maxdepth 1 -type d -print`
        do
          if [ -d $incdir ] 
          then
            if [ $first == 1 ] 
            then
              root_include_path=$incdir
              first=0
            else
              if [[ $incdir != *"CGAL"* ]]
              then
                root_include_path=$root_include_path:$incdir
              fi
            fi
          fi
        done
      fi
    fi
  done
fi 
if [ $offline_main_done == 0 ]
then
  offline_main_done=1
  if [ $first == 1 ] 
  then
    root_include_path=$OFFLINE_MAIN/include
    first=0
  else
    root_include_path=$root_include_path:$OFFLINE_MAIN/include
  fi
  root_include_path=$root_include_path:$OFFLINE_MAIN/include/eigen3:$OFFLINE_MAIN/include/g4detectors:$OFFLINE_MAIN/include/phhepmc:$OFFLINE_MAIN/include/calobase
fi
root_include_path=$root_include_path:$G4_MAIN/include
# add G4 include path
export ROOT_INCLUDE_PATH=$root_include_path
#echo $ROOT_INCLUDE_PATH

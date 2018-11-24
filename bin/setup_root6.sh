#! /bin/bash
unset ROOT_INCLUDE_PATH
export EVT_LIB=$ROOTSYS/lib
first=1
# make sure our include dirs come first in ROOT_INCLUDE_PATH
if [ $# > 0 ]
then
  for arg in "$@"
  do
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
  done
fi 
for incdir in `find $OFFLINE_MAIN/include -maxdepth 1 -type d -print`
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
root_include_path=$root_include_path:$G4_MAIN/include
# add G4 include path
export ROOT_INCLUDE_PATH=$root_include_path
#echo $ROOT_INCLUDE_PATH

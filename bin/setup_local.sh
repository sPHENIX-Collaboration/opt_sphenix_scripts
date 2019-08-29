#! /bin/bash
if [ $# > 0 ]
then
  firsta=1
  firstb=1
  ldpath=""
  bpath=""
  source /opt/sphenix/core/bin/setup_root6_include_path.sh $@
  for arg in "$@"
  do
    libpath=$arg/lib
    binpath=$arg/bin
    if [ -d $libpath ]
    then
      if [ $firsta == 1 ]
      then
        ldpath=$libpath
        firsta=0
      else
        ldpath=${ldpath}:${libpath}
      fi
    fi
    if [ -d $binpath ]
    then
      if [ $firstb == 1 ]
      then
        bpath=$binpath
        firstb=0
      else
        bpath=${bpath}:${binpath}
      fi
    fi
  done
  export LD_LIBRARY_PATH=${ldpath}:$LD_LIBRARY_PATH
  export PATH=${bpath}:${PATH}
  echo LD_LIBRARY_PATH now $LD_LIBRARY_PATH
  echo PATH now $PATH
fi

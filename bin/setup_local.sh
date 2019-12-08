#! /bin/bash
if [ -z "$OPT_SPHENIX" ]
then
  echo OPT_SPHENIX environment variable not set, source the sphenix_setup script
  echo before sourcing this script
  exit 1
fi
if [ $# > 0 ]
then
  firsta=1
  firstb=1
  ldpath=""
  bpath=""
  source ${OPT_SPHENIX}/bin/setup_root6_include_path.sh $@
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

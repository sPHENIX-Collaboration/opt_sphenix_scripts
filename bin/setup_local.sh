#! /bin/bash
if [ -z "$OPT_SPHENIX" ]
then
  echo OPT_SPHENIX environment variable not set, source the sphenix_setup script
  echo before sourcing this script
  exit 1
fi
if [ $# -gt 0 ]
then
  local_firsta=1
  local_firstb=1
  local_ldpath=""
  local_bpath=""
  source ${OPT_SPHENIX}/bin/setup_root6_include_path.sh $@
  for arg in "$@"
  do
    local_libpath=$arg/lib
    local_binpath=$arg/bin
    if [ -d $local_libpath ]
    then
      if [ $local_firsta == 1 ]
      then
        local_ldpath=$local_libpath
        local_firsta=0
      else
        local_ldpath=${local_ldpath}:${local_libpath}
      fi
    fi
    if [ -d $local_binpath ]
    then
      if [ $local_firstb == 1 ]
      then
        local_bpath=$local_binpath
        local_firstb=0
      else
        local_bpath=${local_bpath}:${local_binpath}
      fi
    fi
  done
  export LD_LIBRARY_PATH=${local_ldpath}:$LD_LIBRARY_PATH
  export PATH=${local_bpath}:${PATH}
  echo LD_LIBRARY_PATH now $LD_LIBRARY_PATH
  echo PATH now $PATH
#unset locally used variables
  unset local_binpath
  unset local_bpath
  unset local_firsta
  unset local_firstb
  unset local_ldpath
  unset local_libpath
fi

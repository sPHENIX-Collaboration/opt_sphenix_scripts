#! /bin/csh -f -x
if (! $?OPT_SPHENIX) then
  echo OPT_SPHENIX environment variable not set, source the sphenix_setup script
  echo before sourcing this script
  exit 1
endif
if ($#argv > 0) then
  source ${OPT_SPHENIX}/bin/setup_root6_include_path.csh $*
  set local_ldpath = ""
  set local_bpath = ""
  set local_first=1
  foreach arg ($*)
    foreach local_libpath ( $arg/lib $arg/lib64)
      if (-d $local_libpath) then
        if ($local_first == 1) then
          set local_ldpath = $local_libpath
          set local_first=0
        else
          set local_ldpath =  ${local_ldpath}:${local_libpath}
        endif
      endif
    end
    set binpath = $arg/bin
    if (-d $binpath) then
      set local_bpath=($local_bpath $binpath)
    endif
  end
  if ($local_ldpath != "") then
    setenv LD_LIBRARY_PATH ${local_ldpath}:$LD_LIBRARY_PATH
  endif
  set path = ($local_bpath $path)
  echo LD_LIBRARY_PATH now $LD_LIBRARY_PATH
  echo path now $path
#unset locally used variables
  unset local_binpath
  unset local_bpath
  unset local_first
  unset local_ldpath
  unset local_libpath
endif  

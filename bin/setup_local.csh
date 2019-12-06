#! /bin/csh -f -x
if (! $?OPT_SPHENIX) then
  echo OPT_SPHENIX environment variable not set, source the sphenix_setup script
  echo before sourcing this script
  exit 1
endif
if ($#argv > 0) then
  source ${OPT_SPHENIX}/bin/setup_root6_include_path.csh $*
  set ldpath = ""
  set bpath = ""
  set first=1
  foreach arg ($*)
    set libpath = $arg/lib
    set binpath = $arg/bin
    if (-d $libpath) then
      if ($first == 1) then
        set ldpath = $libpath
        set first=0
      else
        set ldpath =  ${ldpath}:${libpath}
      endif
    endif
    if (-d $binpath) then
      set bpath=($bpath $binpath)
    endif
  end
setenv LD_LIBRARY_PATH ${ldpath}:$LD_LIBRARY_PATH
set path = ($bpath $path)
endif  
echo LD_LIBRARY_PATH now $LD_LIBRARY_PATH
echo path now $path

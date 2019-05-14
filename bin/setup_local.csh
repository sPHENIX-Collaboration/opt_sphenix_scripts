#! /bin/csh -f -x
if ($#argv > 0) then
  source /opt/sphenix/core/bin/setup_root6.csh $*
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

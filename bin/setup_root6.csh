#! /bin/csh -f -x
unsetenv ROOT_INCLUDE_PATH
setenv EVT_LIB $ROOTSYS/lib
set first=1
set offline_main_done=0
# make sure our include dirs come first in ROOT_INCLUDE_PATH, 
# use OFFLINE_MAIN only if it comes in the list of arguments, flag it as used
if ($#argv > 0) then
  foreach arg ($*)
    if ($arg =~ *"$OFFLINE_MAIN"*) then
      set offline_main_done=1
      if ($first == 1) then
        setenv ROOT_INCLUDE_PATH $OFFLINE_MAIN/include
        set first=0
      else
        setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/include
      endif
      setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/include/eigen3:$OFFLINE_MAIN/include/GenFit:$OFFLINE_MAIN/include/g4detectors:$OFFLINE_MAIN/include/g4main:$OFFLINE_MAIN/include/phhepmc:$OFFLINE_MAIN/include/calobase:$OFFLINE_MAIN/include/trackbase_historic
    else
      if (-d $arg) then
        foreach incdir (`find $arg/include -maxdepth 1 -type d -print`)
          if (-d $incdir) then
            if ($first == 1) then
              setenv ROOT_INCLUDE_PATH $incdir
              set first=0
            else
              if ($incdir !~ {*CGAL}) then
                setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$incdir
              endif
            endif
          endif
        end
      endif
    endif
  end
endif  
# add OFFLINE_MAIN include paths by default if not already done
if ($offline_main_done == 0) then
  if ($first == 1) then
    setenv ROOT_INCLUDE_PATH $OFFLINE_MAIN/include
    set first=0
  else
    setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/include
  endif
  setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/include/eigen3:$OFFLINE_MAIN/include/GenFit:$OFFLINE_MAIN/include/g4detectors:$OFFLINE_MAIN/include/g4main:$OFFLINE_MAIN/include/phhepmc:$OFFLINE_MAIN/include/calobase:$OFFLINE_MAIN/include/trackbase_historic
endif
# add G4 include path
setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$G4_MAIN/include
#echo $ROOT_INCLUDE_PATH

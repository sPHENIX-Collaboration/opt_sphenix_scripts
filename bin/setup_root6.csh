#! /bin/csh -f -x
unsetenv ROOT_INCLUDE_PATH
setenv EVT_LIB $ROOTSYS/lib
set first=1
# make sure our include dirs come first in ROOT_INCLUDE_PATH
if ($#argv > 0) then
  foreach arg ($*)
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
  end
endif  
foreach incdir (`find $OFFLINE_MAIN/include -maxdepth 1 -type d -print`)
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
# add G4 include path
setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$G4_MAIN/include
#echo $ROOT_INCLUDE_PATH

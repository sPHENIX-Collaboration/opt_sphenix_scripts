#! /bin/csh -f -x
unsetenv ROOT_INCLUDE_PATH
setenv EVT_LIB $ROOTSYS/lib
# start with your local directory
setenv ROOT_INCLUDE_PATH ./
set local_offline_main_done=0
# make sure our include dirs come first in ROOT_INCLUDE_PATH, 
# use OFFLINE_MAIN only if it comes in the list of arguments, flag it as used
if ($#argv > 0) then
  foreach arg ($*)
    if ($arg =~ *"$OFFLINE_MAIN"*) then
      set local_offline_main_done=1
    endif
    if (-d $arg) then
      foreach local_incdir (`find $arg/include -maxdepth 1 -type d -print`)
        if (-d $local_incdir) then
            if ($local_incdir !~ {*CGAL} && $local_incdir !~ {*Vc} && $local_incdir !~ {*rave}) then
              setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$local_incdir
            endif
        endif
      end
    endif
  end
endif  
# add OFFLINE_MAIN include paths by default if not already done
if ($local_offline_main_done == 0) then
    setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/include
  foreach local_incdir (`find $OFFLINE_MAIN/include -maxdepth 1 -type d -print`)
    if (-d $local_incdir) then
      if ($local_incdir !~ {*CGAL} && $local_incdir !~ {*Vc} && $local_incdir !~ {*rave}) then
        setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$local_incdir
      endif
    endif
  end
endif
# add G4 include path
setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$G4_MAIN/include
# add ROOT Macros
if (-d $OFFLINE_MAIN/rootmacros) then
  setenv ROOT_INCLUDE_PATH ${ROOT_INCLUDE_PATH}:$OFFLINE_MAIN/rootmacros
endif
#echo $ROOT_INCLUDE_PATH
unset local_incdir
unset local_offline_main_done

#! /bin/csh -f -x

# A general purpose login script for sPHENIX.  The allowed arguments
# are '-a' and '-n'
# -a indicates that the script should append to the PATH
# and LD_LIBRARY_PATH rather than replace them, and a trailing
# argument used to indicate the version of the installed software to
# use.  
# -n forces the unset of all relevant variables so you can switch between
# 32 bit and 64 bit setups
# For instance, "new" (also the default value) will point you to
# software in /afs/rhic.bnl.gov/phenix/software/new.  You can be specific if
# you need to be.  Specifying "pro.5" will point you to software in
# /afs/rhic.bnl.gov/phenix/software/pro.5

# Usage: source phenix_setup.csh [-a] [-n] [-h] [version]

# use "limit coredumpsize unlimited" to undo this.
limit coredumpsize 0

set opt_a = 0
set opt_n = 0
set opt_v = "new"

foreach arg ($*)
    switch ($arg)
    case "-a":
	set opt_a = 1
	breaksw
    case "-n":
        set opt_n = 1
	breaksw
    case "-*":
        echo "usage source sphenix_setup.csh [-a] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.407)"
        exit(0)
	breaksw
    case "*":
        set opt_v = $arg
	breaksw
    endsw
end



# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if ($opt_n) then
  unsetenv CERN*
  unsetenv CALIBRATIONROOT
  unsetenv CVSROOT
  unsetenv G4*
  unsetenv LHAPATH
  unsetenv MANPATH
  unsetenv ODBCINI
  unsetenv OFFLINE_MAIN
  unsetenv ONLINE_MAIN
  unsetenv OPT_*
  unsetenv PARASOFT
  unsetenv PERL5LIB
  unsetenv PYTHIA8
  unsetenv ROOTSYS
  unsetenv SIMULATION_MAIN
  unsetenv TSEARCHPATH
endif

# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
set sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`

# turn off opengl direct rendering bc problems for nx
setenv LIBGL_ALWAYS_INDIRECT 1

# turn off gtk warning about accessibility bus
setenv NO_AT_BRIDGE 1

# speed up DCache
setenv DCACHE_RAHEAD
setenv DCACHE_RA_BUFFER 2097152


# Make copies of PATH and LD_LIBRARY_PATH as they were
setenv ORIG_PATH ${PATH}
if ($?LD_LIBRARY_PATH) then
    setenv ORIG_LD_LIBRARY_PATH ${LD_LIBRARY_PATH}
else
    unsetenv ORIG_LD_LIBRARY_PATH
endif
if ($?MANPATH) then
    setenv ORIG_MANPATH ${MANPATH}
else
    unsetenv ORIG_MANPATH
endif

if (! $?OPT_SPHENIX) then
  if (-d /opt/sphenix/core) then
    setenv OPT_SPHENIX /opt/sphenix/core
  endif
endif

if (! $?OPT_UTILS) then
  if (-d /opt/sphenix/utils) then
    setenv OPT_UTILS /opt/sphenix/utils
  endif
endif

# set site wide compiler options (no rpath hardcoding)
if (-f ${OPT_SPHENIX}/etc/config.site) then
  setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config.site
endif
# Perl
if (! $?PERL5LIB) then
   if (-d ${OPT_SPHENIX}/share/perl5) then
     setenv PERL5LIB ${OPT_SPHENIX}/lib64/perl5:${OPT_SPHENIX}/share/perl5
   endif
   if (-d ${OPT_UTILS}/share/perl5) then
     if (! $?PERL5LIB) then
       setenv PERL5LIB ${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     else
       setenv PERL5LIB ${PERL5LIB}:${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     endif
   endif
endif

if (! $?XERCESCROOT) then
  setenv XERCESCROOT /opt/sphenix/core
endif

if (! $?LHAPATH) then
  setenv LHAPATH ${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets
endif

# OFFLINE
if (! $?OFFLINE_MAIN) then
  if (! -d /afs/rhic.bnl.gov/sphenix/new/../$opt_v) then
    set opt_v = "new"
  endif
  setenv OFFLINE_MAIN /afs/rhic.bnl.gov/sphenix/new/../$opt_v/
endif

# Normalize OFFLINE_MAIN 
if (-d $OFFLINE_MAIN) then
  set here=`pwd`
  cd $OFFLINE_MAIN
  set there=`pwd`
  setenv OFFLINE_MAIN `echo $there | sed "s/@sys/$sysname/g"`
  cd $here
endif

# set path to calibration files
if (! $?CALIBRATIONROOT) then
  setenv CALIBRATIONROOT $OFFLINE_MAIN/share/calibrations
endif

if (! $?ONLINE_MAIN) then
  setenv ONLINE_MAIN $OFFLINE_MAIN
endif

# ROOT
if (! $?ROOTSYS) then
    if (-d $OFFLINE_MAIN/root) then
      setenv ROOTSYS $OFFLINE_MAIN/root
    else    
      setenv ROOTSYS $OPT_SPHENIX/root
    endif    
endif

#Pythia8
if (-d $OFFLINE_MAIN/share/Pythia8) then
  setenv PYTHIA8 $OFFLINE_MAIN/share/Pythia8
endif

if (! $?PGHOST) then
  setenv PGHOST phnxdbrcf2
  setenv PGUSER phnxrc
  setenv PG_PHENIX_DBNAME Phenix_phnxdbrcf2_C
endif

# Basic PATH
switch ($HOSTTYPE) 
  case *linux*:
    set path = (/usr/lib64/qt-3.3/bin /usr/local/bin /usr/bin /usr/local/sbin /usr/sbin)
    set manpath = `/usr/bin/man --path`
    breaksw

endsw

set path = (. $path)
set ldpath = .

if (-d $OPT_SPHENIX/bin) then
  set path = ($OPT_SPHENIX/bin $path)
endif

if (-d $OPT_SPHENIX/lib) then
  set ldpath = ${ldpath}:${OPT_SPHENIX}/lib
endif

if (-d $OPT_UTILS/bin) then
  set path = ($OPT_UTILS/bin $path)
endif
if (-d $OPT_UTILS/lib) then
  set ldpath = ${ldpath}:${OPT_UTILS}/lib
endif


if (-d ${OPT_SPHENIX}/man) then
    set manpath = ${manpath}:${OPT_SPHENIX}/man
endif

if (-d ${OPT_SPHENIX}/share/man) then
    set manpath = ${manpath}:${OPT_SPHENIX}/share/man
endif

foreach d (${ONLINE_MAIN}/bin ${OFFLINE_MAIN}/bin ${ROOTSYS}/bin)
  if (-d $d) then
    set path = ($path $d)
  endif
end

set rootlibdir_tmp = `root-config --libdir`
if (-d $rootlibdir_tmp) then
  set here=`pwd`
  cd $rootlibdir_tmp
  set there=`pwd`
  set rootlibdir = `echo $there | sed "s/@sys/$sysname/g"`
  cd $here
endif


# add utils
set ldpath = ${ldpath}:
foreach d (/usr/local/lib64 /usr/lib64 \
           ${ONLINE_MAIN}/lib ${OFFLINE_MAIN}/lib ${rootlibdir} )
  if (-d $d) then
   set ldpath = ${ldpath}:${d}
  endif
end

# Set up Insure++, if we have it
if (! $?PARASOFT) then
  setenv PARASOFT /afs/rhic.bnl.gov/app/insure-7.5.0
endif

if (-d ${PARASOFT}/bin) then
  set path = ($path ${PARASOFT}/bin)
  set ldpath = ${ldpath}:${PARASOFT}/lib
endif

# dCache, if available
if (-d /afs/rhic.bnl.gov/opt/d-cache/dcap/bin) then
    set path = ($path /afs/rhic.bnl.gov/opt/d-cache/dcap/bin)
endif

#add coverity
if (-d /afs/rhic.bnl.gov/app/coverity-8.7.1/bin) then
  set path = ($path  /afs/rhic.bnl.gov/app/coverity-8.7.1/bin)
endif

# Add Geant4
if (! $?G4_MAIN) then
    if (-d $OFFLINE_MAIN/geant4) then
      setenv G4_MAIN ${OFFLINE_MAIN}/geant4
    else
      setenv G4_MAIN ${OPT_SPHENIX}/geant4
    endif
endif

if (-d $G4_MAIN) then
# normalize G4_MAIN to /opt/phenix/geant4.Version
    set here=`pwd`
    cd $G4_MAIN
    set there=`pwd`
    setenv G4_MAIN `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
# this is for later possible use, extract the main version number
    set g4basedir = `basename $G4_MAIN`
    set g4mainversion = `echo $g4basedir | awk -F. '{print $2}'`
    if (-f ${G4_MAIN}/geant4.csh) then
         source ${G4_MAIN}/geant4.csh >& /dev/null
    else
        if (-f ${G4_MAIN}/bin/geant4.csh) then
            set here=`pwd`
            cd $G4_MAIN/bin
            source geant4.csh  >& /dev/null
            cd $here
        endif
    endif

    if (-d ${G4_MAIN}/bin) then
	set  path = ($path ${G4_MAIN}/bin)
    endif
    if (-d ${G4_MAIN}/lib64) then
	set  ldpath = ${ldpath}:${G4_MAIN}/lib64
    endif

endif

#LHAPDF
if (-d ${OPT_SPHENIX}/lhapdf-5.9.1/lib) then
  set  ldpath = ${ldpath}:${OPT_SPHENIX}/lhapdf-5.9.1/lib
endif

# Set some actual environment vars
if ($opt_a) then
    setenv PATH ${ORIG_PATH}:${PATH}
    if (! $?LD_LIBRARY_PATH) then
	setenv LD_LIBRARY_PATH ${ldpath}
    else
	setenv LD_LIBRARY_PATH ${ORIG_LD_LIBRARY_PATH}:${ldpath}
    endif
    if (! $?MANPATH) then
	setenv MANPATH ${manpath}
    else
	setenv MANPATH ${ORIG_MANPATH}:${manpath}
    endif
else
    setenv LD_LIBRARY_PATH ${ldpath}
    setenv MANPATH ${manpath}
endif

#replace @sys by afs sysname (to strip duplicate entries with /@sys/ and /x86_64_sl7/)
setenv PATH  `echo $PATH | sed "s/@sys/$sysname/g"`
setenv LD_LIBRARY_PATH `echo $LD_LIBRARY_PATH | sed "s/@sys/$sysname/g"`
setenv MANPATH  `echo $MANPATH | sed "s/@sys/$sysname/g"`

# strip duplicates in paths
setenv PATH `echo -n $PATH | awk -v RS=: -v ORS=: '! arr[$0]++'` 
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
setenv MANPATH `echo -n $MANPATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
# the above leaves a colon at the end of the strings, so strip the last character
setenv PATH `echo -n $PATH | sed 's/.$//'`
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | sed 's/.$//'`
setenv MANPATH `echo -n $MANPATH | sed 's/.$//'`

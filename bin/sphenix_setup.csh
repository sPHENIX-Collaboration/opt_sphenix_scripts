#! /bin/csh -f -x

# A general purpose login script for sPHENIX.  The allowed arguments
# are '-a', '-n' and '-h'
# -a indicates that the script should append to the PATH
# and LD_LIBRARY_PATH rather than replace them, and a trailing
# argument used to indicate the version of the installed software to
# use.  
# -n forces the unset of all relevant variables so you can switch from a
# previously initialized setup (different build or PHENIX).
# For instance, "new" (also the default value) will point you to
# software in /cvmfs/sphenix.sdcc.bnl.gov/gcc-8.3/release/release_new/new
# You can be specific if you need to be:
# Specifying "ana.230" will point you to software in
# /cvmfs/sphenix.sdcc.bnl.gov/gcc-8.3/release/release_ana/ana.230
# -h just prints help (as does any other -<letter> flag)

# Usage: source phenix_setup.csh [-a] [-n] [-h] [version]

# use "limit coredumpsize unlimited" to undo this.
limit coredumpsize 0

set opt_a = 0
set opt_b = 0
set opt_n = 0
set opt_v = "new"

foreach arg ($*)
    switch ($arg)
    case "-a":
	set opt_a = 1
	breaksw
    case "-b*":
	set opt_b = 1
	breaksw
    case "-n":
        set opt_n = 1
	breaksw
    case "-*":
        echo "usage source sphenix_setup.csh [-a] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.230)"
        exit(0)
	breaksw
    case "*":
        set opt_v = $arg
	breaksw
    endsw
end

# STARs environment contains an alias for pwd which
# throws a monkey wrench into pwd -P
unalias pwd

# unset compiler settings from gcc 8.3 in case they were set
# they wreak havoc if you leave them when using another compiler
unsetenv FC
unsetenv CC
unsetenv CXX
unsetenv COMPILER_PATH

# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if ($opt_n) then
  unsetenv CERN*
  unsetenv CALIBRATIONROOT
  unsetenv CONFIG_SITE
  unsetenv COVERITY_ROOT
  unsetenv CVSROOT
  unsetenv G4*
  unsetenv GSEARCHPATH
  unsetenv LHAPATH
  unsetenv LHAPDF_DATA_PATH
  unsetenv MANPATH
  unsetenv NOPAYLOADCLIENT_CONF
  unsetenv ODBCINI
  unsetenv OFFLINE_MAIN
  unsetenv ONLINE_MAIN
  unsetenv OPT_*
  unsetenv PARASOFT
  unsetenv PERL5LIB
  unsetenv PGHOST
  unsetenv PG_PHENIX_DBNAME
  unsetenv PYTHIA8
  unsetenv PYTHONPATH
  unsetenv ROOTSYS
  unsetenv SARTRE_DIR
  unsetenv SIMULATION_MAIN
  unsetenv TSEARCHPATH
  unsetenv XERCESCROOT
  unsetenv XPLOAD_CONFIG
  unsetenv XPLOAD_CONFIG_DIR
  unsetenv XPLOAD_DIR
endif

# turn off gtk warning about accessibility bus
setenv NO_AT_BRIDGE 1

# Make copies of PATH and LD_LIBRARY_PATH as they were
setenv ORIG_PATH ${PATH}
if ($?LD_LIBRARY_PATH) then
    setenv ORIG_LD_LIBRARY_PATH ${LD_LIBRARY_PATH}
else
    unsetenv ORIG_LD_LIBRARY_PATH
endif
if ($?MANPATH) then
    setenv ORIG_MANPATH ${MANPATH}
    unsetenv MANPATH
else
    unsetenv ORIG_MANPATH
endif

set local_cvmfsvolume=/cvmfs/sphenix.sdcc.bnl.gov/online/Debian

if (! $?OPT_SPHENIX) then
  if (-d ${local_cvmfsvolume}) then
    setenv OPT_SPHENIX ${local_cvmfsvolume}
  endif
endif

# set site wide compiler options (no rpath hardcoding)
if (! $?CONFIG_SITE) then
  if ($opt_v =~ "debug*" ) then
    if (-f ${OPT_SPHENIX}/etc/config_debug.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config_debug.site
    endif
  else
    if (-f ${OPT_SPHENIX}/etc/config.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config.site
    endif
  endif
endif

if (! $?ONLINE_MAIN) then
  setenv ONLINE_MAIN $OPT_SPHENIX/current
endif

# ROOT
if (! $?ROOTSYS) then
    setenv ROOTSYS $OPT_SPHENIX/root
endif

#find root lib and bin dir
if (-f $ROOTSYS/bin/root-config) then
  set rootlibdir_tmp = `$ROOTSYS/bin/root-config --libdir`
  if (-d $rootlibdir_tmp) then
    set here=`pwd`
    cd $rootlibdir_tmp
    set there=`pwd -P`
    set rootlibdir = `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  endif
  set rootbindir_tmp = `$ROOTSYS/bin/root-config --bindir`
  if (-d $rootbindir_tmp) then
    set here=`pwd`
    cd $rootbindir_tmp
    set there=`pwd -P`
    set rootbindir = `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  endif
endif

# set initial paths, all following get prepended
set path = (/usr/local/bin /usr/bin /usr/local/sbin /usr/sbin)
set manpath = `/usr/bin/man --path`

set ldpath = /usr/local/lib64:/usr/lib64

# loop over all bin dirs and prepend to path
foreach bindir (${ONLINE_MAIN}/bin \
                ${OPT_SPHENIX}/bin \
                ${ROOTSYS}/bin)
  if (-d $bindir) then
    set path = ($bindir $path)
  endif
end

#loop over all libdirs and prepend to ldpath
foreach libdir (${ONLINE_MAIN}/lib \
                ${ONLINE_MAIN}/lib64 \
                ${OPT_SPHENIX}/lib \
                ${OPT_SPHENIX}/lib64 \
                ${rootlibdir} )
  if (-d $libdir) then
    set ldpath = ${libdir}:${ldpath}
  endif
end
# loop over all man dirs and prepend to manpath
foreach mandir (${ONLINE_MAIN}/share/man \
                ${OPT_SPHENIX}/man \
                ${OPT_SPHENIX}/share/man \
                ${ROOTSYS}/man )
  if (-d $mandir) then
    set manpath = ${mandir}:${manpath}
  endif
end

# finally prepend . to path/ldpath

set path = (. $path)
set ldpath=.:${ldpath}

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

# strip duplicates in paths
setenv PATH `echo -n $PATH | awk -v RS=: -v ORS=: '! arr[$0]++'` 
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
setenv MANPATH `echo -n $MANPATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
# the above leaves a colon at the end of the strings, so strip the last character
setenv PATH `echo -n $PATH | sed 's/.$//'`
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | sed 's/.$//'`
setenv MANPATH `echo -n $MANPATH | sed 's/.$//'`

#set ROOT_INCLUDE_PATH for root6
#source ${OPT_SPHENIX}/bin/setup_root6_include_path.csh $ONLINE_MAIN

if (-f  ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.csh) then
  source ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.csh
endif

#unset local variables
unset local_cvmfsvolume

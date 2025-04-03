#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Getopt::Long;

sub printhelp;

my $opt_help = 0;
my $timestamp;

GetOptions('help' => \$opt_help,'timestamp' => \$timestamp);
if ($opt_help)
{
    &printhelp;
}
my $dbh = DBI->connect("dbi:ODBC:phnxbld") || die $DBI::error;
if ($#ARGV < 0)
{
    my $getbuilds = $dbh->prepare("select distinct(build) from buildtags order by build");
    $getbuilds->execute() || die $DBI::error;
    while (my @bld = $getbuilds->fetchrow_array())
    {
	print "$bld[0]\n";
    }
    $getbuilds->finish();
    print "\n";
    $opt_help = 1;
    &printhelp;
}
else
{
    my $gettags = $dbh->prepare("select  reponame,tag,date  from buildtags where build = ? order by reponame");
    while ($#ARGV >= 0)
    {
	my $build = $ARGV[0];
	$gettags->execute($build);
	if ($gettags->rows > 0)
	{
	    print "\nBuild: $build\n";
	    while (my @repotags = $gettags->fetchrow_array())
	    {
		print "repository: ", pack('A45', $repotags[0]),"  tag: $repotags[1]";
		if (defined $timestamp)
		{
		    print "  timestamp: $repotags[2]";
		}
		print "\n";
	    }
	}
	shift(@ARGV);
    }
    $gettags->finish();
}

$dbh->disconnect;

sub printhelp
{
    if ($opt_help)
    {
	print "usage: get_build_tags.pl <build>\n";
	print "no <build>: print list of builds in DB\n";
	print "parameters:\n";
	print "--help: this text\n";
	print "--timestamp: print timestamp of tag\n";
	exit(0);
    }
}

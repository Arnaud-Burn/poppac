#!/usr/bin/perl -w

######## POPPAC - Personal OID Printer Paper Check ##############
# Version : 0.7
# Date :  March 27 2014
# Author  : Arnaud Comein (arnaud.comein@gmail.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#################################################################

#Needed for GET SNMP
use BER;
use SNMP_util;
use SNMP_Session;

#Neede for debugging - ~Verbose mode
use strict;
use warnings;

#Vars - "shift" = waitting for arguments - !order! - Undef by default
my $MIB = shift;
my $HOST = shift;
my $dir = "/usr/share/poppac";
my $O;
my $value;
my $tot;
my $lastTot;
my $i = 0;
my $totAll;
my $monthRaed;
my $INI;
my $MONTH;
my $HIST;
my $TOT;
my $LAST;
my $err = "Please, delete the init.txt file which is inside /usr/share/poppac";
my $help = "Correct use : ./poppac-en.pl OID HOSTNAME\n";
my $errfile = "Please, create this folder before /usr/share/poppac";

#Get the hole date in separate vars
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();

#Correcting year (system year starts at 1900)
my $year = $yearOffset + 1900;

#Get current month - January = 0
my $monthnum = $month + 1; #Needed for history
 
my %monthname = (
1 => 'January',
2 => 'February',
3 => 'March',
4 => 'April',
5 => 'May',
6 => 'June',
7 => 'July',
8 => 'August',
9 => 'September',
10 => 'October',
11 => 'November',
12 => 'December',
);

#Help
($MIB) && ($HOST) || die $help;

#GetOID
($value) = &snmpget("public\@$HOST","$MIB");

#Exit in case of connection problem to host
if ($value)
{
	#Is it the first launch ?
	open $INI, "<", "/usr/share/poppac/init.txt" or $i = 1;

	if ($i == 1) #If init doesn't exist, we create files and open them in Write mode
	{	
		mkdir $dir;
		
		open $INI, ">", "/usr/share/poppac/init.txt" or print $errfile and die;
		open $MONTH, ">", "/usr/share/poppac/month.txt";
		open $TOT, ">", "/usr/share/poppac/tot.txt";
		open $LAST, ">", "/usr/share/poppac/last.txt";		
		open $HIST, ">", "/usr/share/poppac/hist.txt";

		$totAll = 0;
		$lastTot = $value;
		$monthRaed = $monthnum;
	}
	else #Otherwise, they're open in Read mode
	{	
		open $MONTH, "<", "/usr/share/poppac/month.txt" or print $err and die;
		open $TOT, "<", "/usr/share/poppac/tot.txt" or print $err and die;
		open $LAST, "<", "/usr/share/poppac/last.txt" or print $err and die;	

		$monthRaed = <$MONTH>;
		$totAll = <$TOT>;
		$lastTot = <$LAST>;
	}

	#Current month usage = SNMP Value - last month - total of history
	$tot = ($value - $lastTot - $totAll);

	#Is the month had changed ?
	if ($monthRaed != $monthnum)
	{
		$totAll = $totAll + $lastTot;
		$lastTot = $tot;
		$tot = ($value - $lastTot - $totAll);
		$i = 2;
	}

	#Send data to Shinken UI
	print "Printed page for $monthname{$monthnum} : $tot * Last month : $lastTot\n";

	#Writting new data into files
	if ($i == 1) 
	{ 
		print $INI $i; #Write only if init.txt had just been created
		print $MONTH $monthnum;
		print $TOT $totAll;
		print $LAST $lastTot;
	}	
	#Writting if month had changed. +> to add writting mode on a read mode file	
	if ($i == 2)
	{ 	
		open $MONTH, "+>", "/usr/share/poppac/month.txt";
		open $TOT, "+>", "/usr/share/poppac/tot.txt";
		open $LAST, "+>", "/usr/share/poppac/last.txt";	
		open $HIST, "+>>", "/usr/share/poppac/hist.txt";

		print $MONTH $monthnum; 
		print $TOT $totAll;
		print $LAST $lastTot;
		
		#Managing the "new year" bug
		if ($month == 0)
		{ print $HIST "$monthname{12} : $lastTot\n***** New Year : $year *****\n"; }
		else { print $HIST "$monthname{$month} : $lastTot\n"; }
	}

	#Closing files
	close $INI;
	close $MONTH;
	close $TOT;
	close $LAST;
	if ($i == 2) { close $HIST; }

}

else 
{ print "Error connection to host $HOST\n"; }

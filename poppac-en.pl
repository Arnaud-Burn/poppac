#!/usr/bin/perl -w

######## POPPAC - Personal OID Printer Paper Check ##############
# Version : 0.71
# Date :  March 27 2014
# Author  : Arnaud Comein (arnaud.comein@gmail.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#################################################################

#Besoin pour les GET SNMP
use BER;
use SNMP_util;
use SNMP_Session;

<<<<<<< HEAD
#Besoin pour le debug - ~mode verbeux sous linux
=======
#Needed for debugging - ~Verbose mode
>>>>>>> b2019fcbfa259c7fb057df9514463a91c8363c17
use strict;
use warnings;

#Variables - "shift" = attente d'argument - !ordre! - Undef par defaut
my $MIB = shift;
my $HOST = shift;
my $FILE = shift;
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

#Déclaration pour récupération de la date
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();

#Ajustement de l'année (la date commence à 1900)
my $year = $yearOffset + 1900;

#Récupération du mois en cours - Janvier = 0 en systeme
my $monthnum = $month + 1; #Besoin pour l'historique

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

#Centralisation des erreurs
my $err = "Please, remove all *-init.txt files inside /usr/share/poppac";
my $help = "Correct use : ./poppac.pl OID HOSTNAME PAPERTYPE[A4B/A4C/A3B/A3C/...]\n";
my $errfile = "Plaese, create directory /usr/share/poppac and give rights on it to your user";;
my $errcon = "Unable to connect to $HOST\n";

#Help
($MIB) && ($HOST) && ($FILE) || die $help;

#GetOID
($value) = &snmpget("public\@$HOST","$MIB");

#Prevoir une sortie si la connexion à l'hote ne se fait pas
if ($value)
{
	#Est-ce la premiere éxécution ?
	open $INI, "<", "/usr/share/poppac/$HOST-$FILE-init.txt" or $i = 1;

	if ($i == 1) #Si le fichier init n'existe pas, on crée les fichiers et les ouvres en écriture.
	{	
		mkdir $dir;
		
		open $INI, ">", "/usr/share/poppac/$HOST-$FILE-init.txt" or print $errfile and die;
		open $MONTH, ">", "/usr/share/poppac/$HOST-$FILE-month.txt";
		open $TOT, ">", "/usr/share/poppac/$HOST-$FILE-tot.txt";
		open $LAST, ">", "/usr/share/poppac/$HOST-$FILE-last.txt";		
		open $HIST, ">", "/usr/share/poppac/$HOST-$FILE-hist.txt";

		$totAll = 0;
		$lastTot = $value;
		$monthRaed = $monthnum;
	}
	else #sinon, on les ouvre en lecture.
	{	
		open $MONTH, "<", "/usr/share/poppac/$HOST-$FILE-month.txt" or print $err and die;
		open $TOT, "<", "/usr/share/poppac/$HOST-$FILE-tot.txt" or print $err and die;
		open $LAST, "<", "/usr/share/poppac/$HOST-$FILE-last.txt" or print $err and die;	

		$monthRaed = <$MONTH>;
		$totAll = <$TOT>;
		$lastTot = <$LAST>;
	}

	#Calcul du total du mois en cours = Valeur SNMP - dernier mois - Totalhistorique
	$tot = ($value - $lastTot - $totAll);

	#Verification si changement de mois
	if ($monthRaed != $monthnum)
	{
		$totAll = $totAll + $lastTot;
		$lastTot = $tot;
		$tot = ($value - $lastTot - $totAll);
		$i = 2;
	}

	#Retour Shinken WebUI
	print "Printed pages for $monthname{$monthnum} : $tot * Last month : $lastTot\n";

	#Ecriture des nouvelles données dans les fichiers
	if ($i == 1) 
	{ 
		print $INI $i; #Ecriture ssi init viens d'etre créé
		print $MONTH $monthnum;
		print $TOT $totAll;
		print $LAST $lastTot;
	}	
	#Ecriture ssi le mois viens de changer. +> pour ajouter ecriture	
	if ($i == 2)
	{ 	
		open $MONTH, "+>", "/usr/share/poppac/$HOST-$FILE-month.txt";
		open $TOT, "+>", "/usr/share/poppac/$HOST-$FILE-tot.txt";
		open $LAST, "+>", "/usr/share/poppac/$HOST-$FILE-last.txt";	
		open $HIST, "+>>", "/usr/share/poppac/$HOST-$FILE-hist.txt";

		print $MONTH $monthnum; 
		print $TOT $totAll;
		print $LAST $lastTot;
		
		#Gestion du passage de Décembre à Janvier sinon normal
		if ($month == 0)
		{ print $HIST "$monthname{12} : $lastTot\n***** New Year : $year *****\n"; }
		else { print $HIST "$monthname{$month} : $lastTot\n"; }
	}

	#Fermeture des fichiers
	close $INI;
	close $MONTH;
	close $TOT;
	close $LAST;
	if ($i == 2) { close $HIST; }

} #Fin de la sortie en cas d'erreur de connexion

else 
{ print $errcon; }

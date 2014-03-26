#!/usr/bin/perl -w

######## POPPAC - Personal OID Printer Paper Check ##############
# Version : 0.61
# Date :  March 26 2014
# Author  : Arnaud Comein (arnaud.comein@gmail.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#################################################################

#Besoin pour les GET SNMP
use BER;
use SNMP_util;
use SNMP_Session;

#Besoin pour le mois
use strict;
use warnings;

#Variables - "shift" = attente d'argument - !ordre! - Undef par defaut
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
my $err = "Veuillez supprimer le fichier init.txt se trouvant dans /usr/share/poppac";
my $help = "Utilisation : ./poppac.pl OID HOSTNAME\n";
my $errfile = "Veuillez créer le dossier /usr/share/poppac";

#Déclaration pour récupération de la date
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();

#Récupération du mois en cours
my $monthnum = $month + 1; #Janvier = 0
 
my %monthname = (
1 => 'Janvier',
2 => 'Fevrier',
3 => 'Mars',
4 => 'Avril',
5 => 'Mai',
6 => 'Juin',
7 => 'Juillet',
8 => 'Aout',
9 => 'Septembre',
10 => 'Octobre',
11 => 'Novembre',
12 => 'Decembre',
);

#Help
($MIB) && ($HOST) || die $help;

#GetOID
($value) = &snmpget("public\@$HOST","$MIB");

#Prevoir une sortie si la connexion à l'hote ne se fait pas
if ($value)
{
	#Est-ce la premiere éxécution ?
	open $INI, "<", "/usr/share/poppac/init.txt" or $i = 1;

	if ($i == 1) #Si le fichier init n'existe pas, on crée les fichiers et les ouvres en écriture.
	{	
		mkdir $dir;
		
		open $INI, ">", "/usr/share/poppac/init.txt" or print $errfile and die;
		open $MONTH, ">", "/usr/share/poppac/month.txt";
		open $TOT, ">", "/usr/share/poppac/tot.txt";
		open $HIST, ">", "/usr/share/poppac/hist.txt";

		$totAll = 0;
		$lastTot = $value;
		$monthRaed = $monthnum;
	}
	else #sinon, on les ouvre en lecture.
	{	
		open $MONTH, "<", "/usr/share/poppac/month.txt" or print $err and die;
		open $TOT, "<", "/usr/share/poppac/tot.txt" or print $err and die;
		open $HIST, "<", "/usr/share/poppac/hist.txt" or print $err and die;	

		$monthRaed = <$MONTH>;
		$totAll = <$TOT>;
		$lastTot = <$HIST>;
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
	print "Impressions pour $monthname{$monthnum} : $tot * Mois dernier : $lastTot\n";

	#Ecriture des nouvelles données dans les fichiers
	if ($i == 1) 
	{ 
		print $INI $i; #Ecriture ssi init viens d'etre créé
		print $MONTH $monthnum;
		print $TOT $totAll;
		print $HIST $lastTot;
	}	
	#Ecriture ssi le mois viens de changer. +> pour ajouter ecriture	
	if ($i == 2)
	{ 	
		open $MONTH, "+>", "/usr/share/poppac/month.txt";
		open $TOT, "+>", "/usr/share/poppac/tot.txt";
		open $HIST, "+>", "/usr/share/poppac/hist.txt";	

		print $MONTH $monthnum; 
		print $TOT $totAll;
		print $HIST $lastTot;
	}

	#Fermeture des fichiers
	close $INI;
	close $MONTH;
	close $TOT;
	close $HIST;

} #Fin de la sortie en cas d'erreur de connexion

else 
{ print "Connexion impossible à :$HOST:\n"; }

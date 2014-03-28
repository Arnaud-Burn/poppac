poppac
======

*Personnal OID Printer Paper Check

>> What is it ?

Shinken module which takes as argument an OID and hostname.
It will bring into Shinken the total pages printed for this month and for the passed one.
It's regardless of brand or model due to the fact you can send the correct personnalized OID of your printer to this module.

>> Why to ?

To avoid the use of too bigger scripts which are not always stable with new Shinken/Naggios version.
Plus the fact that there were no really many scripts to get personnal information about paper type consummed directly inside the monitoring interface.
This script had been KISSed (Keep It Simply, Stupid).
It will no impact on future updates.

>> Could you be more complete about the features ?

* Shows the Total printed pages for the actual month plus the name of the month.
* Shows the total printed pages for the last month.
* Manage the month change automatically, based on system time.
* Detect and create files automatically at first launch.
* Detect and warn the user for connection problem to host.
* Detect and warn the user for corrupted or missing files.
* Detect system crash.

>> How does it work ?

Just call 
<<<<<<< HEAD
./poppac.pl OID HOSTNAME PAPERTYPE[A4B/A4C/A3B/A3C/...] (for French version)

OR

./poppac-en.pl OID HOSTNAME PAPERTYPE[A4B/A4C/A3B/A3C/...] (for English version)
=======
./poppac.pl OID HOSTNAME (for French version)   OR   ./poppac-en.pl OID HOSTNAME (for English version)
>>>>>>> b2019fcbfa259c7fb057df9514463a91c8363c17

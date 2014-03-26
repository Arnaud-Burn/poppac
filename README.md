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
./poppac.pl OID HOSTNAME

>> What about the install process ?

At the moment, it's manual:
1. Downlaod the script .pl
2. place it inside your "libexec" folder
3. gives your nagios/shinken user rights on it
4. Create a new template and service definition for your monitoring system
5. into the "commands.cfg", just call the script for each type of paper you want to check, just change the OID
6. link some hosts to this template

Bur, in the futur, I'd like to package it in way to make it available into Shinken.io for automatic install

>> Are there some dependancies ?

Classic PERL dependancies.
# perl -MCPAN -e 'install Encoding::BER'
# perl -MCPAN -e 'installConvert::BER'

If another module is needed,
just install it the same way the two others upper (and changing for module name)

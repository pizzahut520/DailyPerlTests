# ---------------------------------------------------------------------------------------------------
# HLE 10/08/2015
# Ajout pour capturer les evenements die
require "mega/error_handler.pl";
# ---------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------
# HGT / XYU 6/10/2011
# Ajout pour tracer les scripts appel�s
system("w:\\tools\\scripttrace.pl $0");
# ---------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
# 28/11/2011 HGT
# Ajout du Media dans le mail d'�chec de construction.
#-----------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# HGT 10/1/2012
# Mise en place d'un flag stop
# ---------------------------------------------------------------------------------------------------

# use strict;
# use warnings;

use Mega::Exploit;


ScriptFindAndExecute("770", "tst", "start $WindowsTitle /wait", "expmaster_buildmsi_msp.pl", "770 exp  w:\\temp\\flagmsp.flag");
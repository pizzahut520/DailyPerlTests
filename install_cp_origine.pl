# ---------------------------------------------------------------------------------------------------
# HLE 10/08/2015
# Ajout pour capturer les evenements die
require "mega/error_handler.pl";
# ---------------------------------------------------------------------------------------------------

#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================


use Win32::Api;
use Getopt::Long;
use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
use Win32::File;
use Win32::FileOp;
use File::DosGlob 'glob';
use File::Basename;
use File::Path;
use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );
use Mega::Logger;
use Mega::Exploit;
use MIME::Lite;
use Net::SMTP;
use Sys::Hostname;






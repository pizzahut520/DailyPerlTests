#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================

use Win32::GUI();
use Win32::File;
use Win32::FileOp;
use Win32::OLE;
use Win32::OLE qw(in with); 
use Win32::OLE::Const 'Microsoft ActiveX Data Objects';
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::Api;
use File::Basename;
use File::Path;
use File::Path qw(make_path);
use Date::Calc qw(:all);
use MIME::Lite;
use Net::SMTP;
use Mega::Exploit;
use POSIX qw/strftime/;
use DBI;



	$languages = $Envs->Languages();
	foreach $langue in($languages){
		print $langue->Megafield();
		
	
	}
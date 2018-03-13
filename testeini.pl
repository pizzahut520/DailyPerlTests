

use Win32::GUI;
use Win32::FileOp;
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Mega::Exploit;
use Mega::RTC::Projects;

$File_Ini         = "w:/tools/versions.ini";



@L_Versions = Read_Ini_Sections($File_Ini);

print @L_Versions;
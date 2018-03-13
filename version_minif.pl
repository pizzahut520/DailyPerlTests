

use Win32::File;
use Win32::FileOp;

use Mega::Exploit;
use Sys::Hostname;
$File_Ini = "w:/tools/Versions.ini";
$buildincr       =  Read_Ini($File_Ini, "750","buildincrement","");
print $buildincr;

  # Loguer le script qu'on appelle
  my $host = hostname();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year += 1900;
  $mon += 1;

  $mday = sprintf("%02d",$mday);
  $mon = sprintf("%02d",$mon);
  $sec = sprintf("%02d",$sec);
  $min = sprintf("%02d",$min);
  $hour = sprintf("%02d",$hour);

  my $file_origine = "C:\\temp\\mega_all.js";
  my $file_copy = "C:\\temp\\mega_all_copy.js";
  
  

  if(open(COPY, ">" , $file_copy ))
  { 
    print COPY "/*build: $buildincr  date : $year/$mon/$mday;$hour:$min:$sec;*/\n";
    open(my $fh,$file_origine);
	while (my $row = <$fh>) {
	  print COPY "$row";
	}	
	close(COPY);
  }  
  
  unlink $file_origine;
  rename($file_copy,$file_origine); 
  
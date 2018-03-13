use Mega::Exploit;

$Version = 770;
$Espace = "int";

$setupini = "\\\\ntas\\public\\DailyBuild\\Mega Modeling\\_default" . "-" . "$Version" . "-" . "$Espace.ini";
$destination = Read_Ini($setupini, "_default","InstallSource","");

$destination =~ s/\\Disk1//g;

print $destination;



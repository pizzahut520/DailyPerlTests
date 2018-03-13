use Mega::Exploit;




$version = shift;
$espace = shift;


if(lc(substr("$machine", 0, 2)) eq lc("QA")) {  
  $setupini = "r:\\DailyBuild\\Mega Modeling\\$Master" . "-" . "$version" . "-" . "$espace.ini";
} else {
  $setupini = "\\\\ntas\\public\\DailyBuild\\Mega Modeling\\$Master" . "-" . "$version" . "-" . "$espace.ini";
}
$expVersionIniPath = "W:\\tools\\versions.ini";

$InstallSource  = Read_Ini($setupini, "$Master","InstallSource","");
my$pos = index("$InstallSource", "\\\\ntas\\public");
if ($pos != -1) {
  $InstallSource = "r:".substr("$InstallSource", length("\\\\ntas\\public"), length("$InstallSource"));
}


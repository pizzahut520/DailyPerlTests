
$file_log = "c:\\temp\\signlog.txt";
if(-e $file_log){
  unlink $file_log;
}
$powershell_path = `where powershell`;
$set = `$powershell_path -command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned"`;
$result = `$powershell_path  -command "C:\\Users\\xyu\\Desktop\\Scriptes\\ps1\\get_built_files.ps1 770 $file_log"`;
open(FILE, $file_log) or die "Can't read file 'filename' [$!]\n";  
@document = <FILE>; 
close (FILE);  
foreach $line ( @document){
  print $line;
}




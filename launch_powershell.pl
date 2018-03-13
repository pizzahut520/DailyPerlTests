

use Mega::Exploit;


$vm_name = shift;

$my_ps1_script = 'W:\\tools\\exp_ResetVM_ps.ps1';

$powershell_bin = `where powershell`;

chomp($powershell_bin);

# $cmd = $powershell_bin." -command ".$my_ps1_script." ".$vm_name;
 $cmd = "powershell -file $my_ps1_script $vm_name 2>c:\\error.txt";
print $cmd;
print systemWithCheck($cmd);
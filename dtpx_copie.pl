

use Win32::File;
use Win32::FileOp;
use Mega::Logger;

my $path_dtpx_origine = "$PathOrigineVersion\\code\\dtpx";
my $path_dtpx_target = "$PathTarget\\Hopex";
$Logger->log_print("    $pathOrigineJSMinified_hopex\\*.*  => $pathTargetJSMinified_hopex\n");
CopyEx("$path_dtpx_origine\\*.*" => "$path_dtpx_target", FOF_FILESONLY|FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);

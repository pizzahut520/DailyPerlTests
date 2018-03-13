use Win32::File;
use Win32::FileOp;

# xyu à la demande de PGR
# en 770 on a embarquer la minification de la 762
$minification762 = "W:\\762\\Fournitures\\minification";
$minification770 = "W:\\770\\Fournitures.int\\minification";
CopyEx("$minification762\\*.*" => "$minification770",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
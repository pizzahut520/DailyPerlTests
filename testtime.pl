use Win32::File;
use Win32::FileOp;
use Net::FTP;
use Net::Ping;
use MIME::Lite;
use Net::SMTP;
use Cwd;
use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );
use File::Path;
use File::stat;
use File::Basename;
use Mega::Logger;
use Getopt::Long;
use POSIX qw/strftime/;
use Mega::Exploit;
$jour= strftime "%w", localtime;
$heureactuelle = localtime(time());
@temps = split(/ +/,$heureactuelle);
@heure = split(/:/,$temps[3]);


print $heureactuelle;

use Win32::Api;
use Win32::FileOp;
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Date::Calc qw(:all);
use MIME::Lite;
use Net::SMTP;
use File::Path;
use File::Basename;
use Mega::FileMngt;
use Mega::Exploit;
use Sys::Hostname;
use POSIX qw/strftime/;
use Mega::RTC::Sendmail;


Send_mail_master("pizza.yu@gmail.com","c:\\temp\\masterDebugAddOn.log");


sub Send_mail_master {
    my $dest   = shift;
    my $attach = shift;
    
    $sujet = "Your Chrismas Gift Goes TO----->";
    $texte  = "hello, pizza has written a little script that rolls the lottery for the christmas gift. Cf attached file to see <Who you >";
    
   
    
   
   

    my $Message = new MIME::Lite 
    From =>'exploitation@mega.com', 
    To =>'xyu@mega.com', 
    Subject =>$sujet,
    Type =>'multipart/mixed'; 
    # Ajoutez le message (texte ou html)
    attach $Message 
        Type =>'TEXT', Data =>"$texte";

    # Ajoutez un document log
    attach $Message 
        Type =>'application/log',Path =>$attach,Filename =>$filename; 

    $user="exp2";
    $pass="exp06";
    MIME::Lite->send('smtp', 'exh.fr.mega.com', AuthUser=>$user, AuthPass=>$pass);
   
    $Message->send('smtp', 'exh.fr.mega.com', Timeout=>60, Hello=>'mega.com');
}
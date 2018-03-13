use Mega::Exploit;
use Mega::Synergy::Sessions;




my $mode = $ARGV[0];
my $message;
if(lc($mode) eq "start"){
	$message = "Rappel, il reste une heure pour livrer et merger avant l'exploit de 16h30.";
}
if(lc($mode) eq "stop"){
	$message = "La remonte de tache est fini, vous pouvez livrer ce que vous voulez.";
}




##################################################################################
# copie coller d'un autre script: exp_atf.pl
#
# check session ccm, si ça existe, l'utilise, sinon en cree une autre.
##################################################################################
print "#############  preparation d'une session synergy ##########\n";

$userI = Win32::LoginName();    
$ccm_db = "modeling";
$ccm_interface = "cli";

set_synergy_env($ccm_db,$ccm_interface);
set_exploit_env($ccm_db);

print "\nSearching for opened sessions of IBM Rational Synergy on database $ccm_db...";
my $chksession = ccm_check_session($ccm_db,$ccm_interface);

my $bOkSession;
my $NewCcmAddr;

if( ! $chksession ) {

    print "\nNo session opened on $ccm_db database\n";
    print "\nOpening new session...";
    $NewCcmAddr = ccm_start_session($ccm_db,$ccm_interface);
    if($NewCcmAddr){
        print "\nOpened\n";
    } else {
        print "\nError appeared while opening a new session. Please check IBM Rational Synergy log files or contact build management team.\n";
        exit 0;
    }
} else {
    print "\nOne session found on $ccm_db database in $ccm_interface mode\n";
    print "\nConnecting to this session...";
    $bOkSession = ccm_use_session($chksession);
    if($bOkSession){
        print "\nConnected\n";
    } else {
        print "\nError appeared while connecting to an opened session. Please check IBM Rational Synergy log files or contact build management team.\n";
        exit 0;
    }
}# fin de copie coller d'un autre script: exp_atf.pl
print "##############  fin de la preparation Session Synergy ###############\n";
my $set_admin = "ccm set role ccm_admin";
($pid = open(PIPE, "$set_admin |")) or die "Impossible d'exécuter : $!\n";
while (defined($line = <PIPE>))
{
	print "$line";
}


# $PgmVar = "ccm message /d \\\\semtex\\ccmdata\\mega32";
$PgmVar = "ccm message /u xyu \"$message\"";

print "$PgmVar\n";
($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
while (defined($line = <PIPE>))
{
	print "$line";
}
close(PIPE);  


ccm_stop_session();

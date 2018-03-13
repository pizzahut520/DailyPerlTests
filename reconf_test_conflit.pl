use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::FileOp;
use Date::Calc qw(:all);
use Mega::Exploit;
use Mega::Synergy::Sessions;

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

            my $set_admin = "ccm set role build_mgr";
            ($pid = open(PIPE, "$set_admin |")) or die "Impossible d'exécuter : $!\n";
            while (defined($line = <PIPE>))
            {
                print "$line";
            }


    my $reconf_inc = "X:\\wa\\expl-dev\\expl";
    print $reconf_inc."\n";
    
    ($pid = open(PIPE, "ccm reconf $reconf_inc /r |")) or die "Impossible d'exécuter : $!\n";
    while (defined($line = <PIPE>))
    {
        print "$line";
		if($line =~ m/work area conflicts/){
		print "#ERROR: WorkArea conflict détecté, Resoudre ce conflit à la main puis relancer l'outil, Execution Abandonnée...";
			exit;
		}

    }
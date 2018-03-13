#=====================================================================================================
#							INCLUDED MODULES
#=====================================================================================================


use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::File;
use Win32::FileOp;
use Mega::Exploit;
use Mega::Synergy::Sessions;


my $version = $ARGV[0];
my $espace = $ARGV[1];
my $project = $ARGV[2];
my $reconf = $ARGV[3];
my $out_put_path = $ARGV[4];


$project = lc($project);

printInfo("Start");

if($reconf eq 1){
	printInfo("Reconfiguration: YES");
}else{
	printInfo("Reconfiguration: NO");
}


if(!$out_put_path){
	$out_put_path = "w:\\temp\\new_minification";
}
printInfo("Output Directory: $out_put_path");
if(! -d $out_put_path){
	printInfo("Output Directory: $out_put_path doesn\'t exist, Creating...");
	mkdir($out_put_path);
}


# le dossier où on va pré-stocker les sources JS.
my $PathTarget = "W:\\$version\\InstallCode\\$project";

my $target_disc_letter = "X:";
if($espace ne "int" && $espace ne "tst" && $espace ne "iqa" && $espace ne "tch" && $espace ne "pro"){
	$target_disc_letter = "V:";
	my $user = lc(Win32::LoginName());
	$espace = $user;
	$PathTarget = "C:\\temp\\minification\\$version\\InstallCode\\$project";
}

$wa_path = "$target_disc_letter\\wa\\code-$version.$espace";
if(! -d $wa_path){
	printError("WA path directory doesn\'t exist, Abort.");
	exit;

}

my $projet_ccm = "";
if($project eq "hopex"){
	$projet_ccm = "dtpx";
}
if($project eq "advisor"){
	$projet_ccm = "advr";
}

printInfo("Target WA: $projet_ccm-$version.$espace");

my $file_input = "$wa_path\\code\\_exp\\js_minification_list_".$project.".txt";
printInfo("reference File location: $file_input");
if(! -e $file_input){
	printError("reference File doesn\'t exist, Abort.");
	exit;
}






my $minification_tool = "w:\\tools\\minification.jar";
my $source_map = $out_put_path."\\mega_all.map";
my $file_out_put = $out_put_path."\\mega_all.js";



# denine the original path of the copy
my $path_origine = "$wa_path\\code\\$projet_ccm";
if($projet_ccm eq "advr"){
	$path_origine = $path_origine."\\mega advisor\\dotnet";
}


# reconfiguration

if($reconf eq 1){
	printInfo("Preparing Session Synergy");
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
	}

	
	my $set_mgr = "ccm set role build_mgr";
    ($pid = open(PIPE, "$set_mgr |")) or die "Impossible d'exécuter : $!\n";
    while (defined($line = <PIPE>))
    {
        print "$line";
    }
    
	my @path_to_update=("$wa_path\\code\\_exp","$wa_path\\code\\$projet_ccm");
	
    foreach $path (@path_to_update){
		printInfo("Reconfiguring : $path.");		
		($pid = open(PIPE, "ccm reconf $path /r |")) or die "Impossible d'exécuter : $!\n";
		while (defined($line = <PIPE>)){
			print "$line";
			if($line =~ m/work area conflicts/){
				printError("WorkArea conflict détecté, Resoudre ce conflit à la main puis relancer l'outil, Execution Abandonnée...");
				exit;
			}
		}
		close(PIPE);	
	}
}


# denine the target path of the copy

if (chdir("$PathTarget")) {
printInfo("Deleting the files existed in path: $PathTarget");	
	Mega_del_tree("$PathTarget");
}
printInfo("Copying from $path_origine\\\\*\" TO \"$PathTarget");
CopyEx("$path_origine\\*" => "$PathTarget",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);


# 
if($project eq "hopex"){
	$target_minification = $PathTarget."\\script\\mega";
}
if($project eq "advisor"){
	$target_minification = $PathTarget."\\mega";
}
printInfo("target_minification = $target_minification");



open (INPUT, $file_input) or die "#ERROR: cannnot open the input file $file_input";
close (INPUT);
printInfo("Starting Minifying Js Sources...");
printInfo("File input: $file_input");
printInfo("Minification will be operated in DIR: $target_minification");

 

my $command = "java -jar ".$minification_tool." $file_input  $file_out_put  $source_map ";

if (chdir("$target_minification")) {			 
printInfo("Minification Command : $command");
printInfo("minifying...");
system($command);		
open (CONT, ">>$file_out_put") or die "cannnot open the input file $file_out_put";
print CONT "\n//# sourceMappingURL=$source_map";
close (CONT); 
}

# fermer la session CCM
printInfo("Fermer la session CCM");
ccm_stop_session();


sub printInfo{
	my $str = shift;
	print "#INFO : $str\n";

}

sub printError{
	my $str = shift;
	print "#ERROR : $str\n";

}

use Mega::Exploit;
use Mega::Synergy::Sessions;

my $version = lc($ARGV[0]);
my $espace_source = lc($ARGV[1]);
my $code_java = lc($ARGV[2]);
my $project_mega = lc($ARGV[3]);

if($project_mega eq ""){
	
	printError("Il faut mettre au moins un Projet Synergy pour aligner.");
	exit;
} 

my $espace_local = lc(Win32::LoginName());

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



$project_mega = $code_java.";".$project_mega;
my @projects = split(/;/, $project_mega);
foreach $proj (@projects){
	
	printInfo("Processing Project : $proj Started");
	my $cmd_diff = "ccm query \"is_member_of('$proj-$version.$espace_source') and not is_member_of('$proj-$version.$espace_local')\" -f '%objectname'";
	printInfo("Executing Command: $cmd_diff");
	my @source_list = `$cmd_diff`;
	
	foreach $line (@source_list){
		
		if($proj eq "code"){
			my @info_tmp = split(/:/,$line);			
			if($info_tmp[1] ne "incl"){
				next;
			}
		}
		
		
		my @lines = split(/'/,$line);
		my $fic_name = $lines[1];
		
		
		
		my @name_array = split(/-/,$fic_name);
		my $real_name = $name_array[0];
		$real_name_dup = $real_name;
		$real_name_dup =~ s/\./\\./g;
		# print $fic_name."\n";
			
		my $get_path = "ccm finduse -prep_proj $fic_name";
		($pid = open(PIPE, "$get_path |")) or die "Impossible d'ex�cuter : $!\n";
		while (defined($l = <PIPE>))
		{
			if($l =~ m/@/){
			# print $l;
				
				my @l_split = split(/$real_name_dup/,$l);
				my $fic_path = $l_split[0];
				$fic_path =~ s/\s+//g;
				
				# printInfo("$real_name");
				
				my $wa_fic_path = "V:\\wa\\";
				if($proj ne "code"){		
					if($code_java eq "code"){ 
						$wa_fic_path.= "code-$version.$espace_local\\code\\";
					}
				}else{
					$wa_fic_path.= "code-$version.$espace_local\\";
				}	
				
				if($proj ne "java"){
					if($code_java eq "java"){
						$wa_fic_path.= "mjava-$version.$espace_local\\mjava\\";
					}
				}else{
					$wa_fic_path.= "mjava-$version.$espace_local\\";
				}
				
				
				$wa_fic_path.= $fic_path;
				printInfo("Replacing: ".$wa_fic_path."$real_name");
				printInfo("By: $fic_name\n");
				
				if(chdir($wa_fic_path)){
					my $ccm_use = "ccm use $fic_name";
					($pid = open(PIPE, "$ccm_use |")) or die "Impossible d'ex�cuter : $!\n";
					while (defined($exec_ccm_use = <PIPE>)){
						print $exec_ccm_use
					}
				}
				print "\n\n";
				last;
			}
		}
		
	}
	printInfo("Replacement finished");
	printInfo("We execut the command of listing diff again:");
	
	
	($pid = open(PIPE, "$cmd_diff |")) or die "Impossible d'ex�cuter : $!\n";
	while(defined($l = <PIPE>))
	{
		# print "$l";
	}
	printInfo("Processing Project $proj finished;");
	
}



	printInfo("The End");






















sub printInfo{
	my $str = shift;
	print "#INFO : $str\n";

}

sub printError{
	my $str = shift;
	print "#ERROR : $str\n";

}










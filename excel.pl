use Spreadsheet::WriteExcel;
use Mega::Synergy::Sessions;
use Mega::Exploit;



# Préparation de CR liste
my $file_input = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\cr_list.txt";
my $file_output = "c:\\temp\\CR_forme.xls";
print "#############  preparation d'une session synergy ##########\n";

	
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


my @cr_list=();
open (FILE, $file_input);
my $cr_list_string;
foreach $line (<FILE>)  {   
    
    my @line_array = split(/;/,$line);
	for (my $i = 0; $i < scalar(@line_array); $i++) {
		
		if($i eq scalar(@line_array)-1){
			$cr_list_string .= "cr('$line_array[$i]')";
		}else{
			$cr_list_string .= "cr('$line_array[$i]') or ";
		}
		
	}
}

$cmd = "ccm query /t problem \"$cr_list_string\" -u -f  %problem_number;%release;%crstatus;%product_version;%deadline;%Internal_Tag;%resolver;%problem_synopsis";
print $cmd."\n";
@CR_line = `$cmd`;  
  # ccm_stop_session();
  # print @CR_line;
  # exit;

# Create a new Excel workbook
my $workbook = Spreadsheet::WriteExcel->new($file_output);

# Add a worksheet
$worksheet = $workbook->add_worksheet();
  
# Write a formatted and unformatted string, row and column notation.
$col = $row = 1;

foreach $cr (@CR_line){
	
	
	$col=1;
	my @cr_info = split(";",$cr);
	# my $cr_number 			= $cr_info[0];
	# my $release   			= $cr_info[1];
	# my $status 				= $cr_info[2];
	# my $product_version 	= $cr_info[3];
	# my $deadline 			= $cr_info[4];
	# my $internal_tag 		= $cr_info[5];
	# my $resolver 			= $cr_info[6];
	# my $problem_synopsis 	= $cr_info[7];
	
	foreach $champ (@cr_info){
		chomp($champ);
		$worksheet->write($row, $col, $champ);
		$col++;
	}

	$row++;
}	

$workbook->close();
ccm_stop_session();
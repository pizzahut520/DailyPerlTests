use Mega::RTC::Sessions_test;
use Mega::RTC::Sendmail;
use Mega::RTC::Changeset;
use Mega::RTC::ChangesetManagement;
use Mega::RTC::Snapshot;
use Mega::RTC::Streams;
use Mega::RTC::CURL;




my ($version_from, $espace_from, $version_to, $espace_to) = @ARGV;


my $path_data_stock = "c:\\rtc_temp\\Data";
my $ref_file = $path_data_stock."\\Difference_".$version_from.".".$espace_from."_VS_".$version_to.".".$espace_to.".txt";


my @diff_array = ();


print "Openning Session RTC with CURL...\n";
if(rtc_curl_connect()){
	print "#OK: Session Opened";
}else{
	print "#KO: Open Session Failed";
	exit 1;
}


$bOk = rtc_start_session();
if($bOk){
	
	rtc_get_changesets_compare("stream","$version_from.$espace_from.stream","stream","$version_to.$espace_to.stream",\@diff_array,"code");

	foreach my $changeset (@diff_array){
		
		if(!defined($changeset->{workitems})){
			my $uuid = $changeset->{uuid};
			printInfo("The changeset $uuid has no WorkItem associated.");
		}else{
										
			my @current_cr_workitems = @{$changeset->{workitems}};
			foreach my $wi (@current_cr_workitems){
				# récupér le WI_number pour le WI accosié avec le changeSet courante.
				printInfo($wi->{"workitem-number"});
				
				# call function pour récuperer plus d'info de cette WI/
				

				
				
			}
		
		
		}
	
	}
	

}
 





sub printInfo(){
	my $str = shift;
	print "#INFO: $str\n";
}


sub printErr(){
	my $str = shift;
	print "#ERR: $str\n";
}















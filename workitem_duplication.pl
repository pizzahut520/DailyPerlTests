use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Mega::Exploit;
use Mega::RTC::CURL;
use Mega::Synergy::Sessions;
use File::stat;
use XML::Simple;
use Data::Dumper;

  


# 1 lancer un requete pour recuperer les CR qui sont arbitrée "to_be_migrate"

# lancement de session synergy
my $NewCcmAddr = ccm_start_session("modeling","cli");
if($NewCcmAddr){
    print "\nOpened\n";
} else {
    print "\nError appeared while opening a new session. Please check Synergy/CM log files or contact build management team.\n";
    exit 1;
}


$server_url = "https://vp-pgr-rtc.fr.mega.com:9443";


# %problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%resolver#%hardware#%Internal_Tag#%keyword#%Impact#%Test_data__Disk#%Test_data__SQL#%QA_Code#%support_number#%ecr_number#

# my @CR_list = `ccm query /type problem "problem_number='46343' or problem_number='46535' or problem_number='46575' or problem_number='46577' or problem_number='46579' or problem_number='46580' or problem_number='46586' or problem_number='46602'" -u -f "%problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%hardware#%Internal_Tag#%keyword#%Impact#%QA_Code#%support_number#%ecr_number#%Test_data__Disk#%Test_data__SQL"`;


my @CR_list = `ccm query /type problem "assignment_date>time('%this_week_begin')" -u -f "%problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%hardware#%Internal_Tag#%keyword#%Impact#%QA_Code#%support_number#%ecr_number#%Project#%Test_data__Disk#%Test_data__SQL"`;
print @CR_list;


if(!@CR_list){
	print "The query to Rational Change returns nothing.\nAbort...";
	exit 1;
}


print "Openning Session RTC with CURL...\n";
if(rtc_curl_connect()){
	print "#OK: Session Opened";
}else{
	print "#KO: Open Session Failed";
	exit 1;
}



# 2 boucler sur la CR, generer le ficheir xml à partir du template,
foreach $cr (@CR_list){
	# chomp($cr);
	$cr =~ s/\r//g;
	$cr =~ s/<void>//g;
	$cr =~ s/ç/c/g;
	$cr =~ s/[éèêë]/e/g;
	$cr =~ s/[àâ]/a/g;
	$cr =~ s/[ôö]/o/g;
	$cr =~ s/[îï]/i/g;
	$cr =~ s/[ùü]/u/g;	
	$cr =~ s/[«»]/\"/g;
	$cr =~ s/\’/\'/g;
	
	($problem_number,$problem_synopsis,$enterer,$release,$resolver,$request_type,$Front_End,$Estimate,$Priority,$severity,$hardware,$Internal_Tag,$keyword,$Impact,$QA_Code,$support_number,$ecr_number,$Project,$Test_data__Disk,$Test_data__SQL) = split (/#/, $cr, 20);
	$file_xml = "c:\\temp\\".$problem_number."_wi_creation.xml";
	print "\n".$problem_number."\n";
	# initialisation de XML de la céation.
	open(XML,">$file_xml");
	print XML "<oslc_cm:ChangeRequest
    xmlns:oslc_cm=\"http://open-services.net/xmlns/cm/1.0/\"
    xmlns:dc=\"http://purl.org/dc/terms/\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:calm=\"http://jazz.net/xmlns/prod/jazz/calm/1.0/\"
    xmlns:rtc_cm=\"http://jazz.net/xmlns/prod/jazz/rtc/cm/1.0/\"
    xmlns:oslc_pl=\"http://open-services.net/ns/pl#\">\n";
	
	
	

	#%problem_number -> CR_Origine
	print XML "<rtc_cm:cr_origine>$problem_number</rtc_cm:cr_origine>\n";
	
	#%problem_synopsis -> <dc:title>x_synopsis_x</dc:title>
	print XML "<dc:title>$problem_synopsis</dc:title>\n";
	
	#%enterer  $enterer 
	print XML "<rtc_cm:cr_origine_creator rdf:resource=\"$server_url/jts/users/xyu\"/>\n";

# à définir	
	#%release
	print XML "";
# à définir			
	#%resolver
	print XML "";		
# Attendre la definition de mapping de type	
	#%request_type
	print XML "";

	#%Front_End
	if(lc($Front_End) eq "any" ){
		print XML "<rtc_cm:front rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/front_end/front_end_any\"/>\n";
	}
	if(lc($Front_End) eq "windows front-end"){
		print XML "<rtc_cm:front rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/front_end/windows_front_end\"/>\n";
	}
	if(lc($Front_End) eq "web front-end"){
		print XML "<rtc_cm:front rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/front_end/web_front_end\"/>\n";
	}
	
	#%Estimate
	$Estimate = $Estimate*3600000;
	print XML "<rtc_cm:estimate>$Estimate</rtc_cm:estimate>\n";
	
	#%Priotity
	if(lc($Priority) eq "any" ){
		print XML "<oslc_cm:priority rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/priority/priority.literal.l1\"/>\n";
	}
	if(lc($Priority) eq "low" ){
		print XML "<oslc_cm:priority rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/priority/priority.literal.l2\"/>\n";
	}
	if(lc($Priority) eq "medium" ){
		print XML "<oslc_cm:priority rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/priority/priority.literal.l3\"/>\n";
	}
	if(lc($Priority) eq "high" ){
		print XML "<oslc_cm:priority rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/priority/priority.literal.l4\"/>\n";
	}

	#%severity severity
	if(lc($severity) eq "any" ){
		print XML "<oslc_cm:severity rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/severity/severity.literal.l1\"/>\n";
	}
	if($severity =~ m/00/ ){
		print XML "<oslc_cm:severity rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/severity/severity.literal.l6\"/>\n";
	}
	if($severity =~ m/10/ ){
		print XML "<oslc_cm:severity rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/severity/severity.literal.l5\"/>\n";
	}
	if($severity =~ m/20/ ){
		print XML "<oslc_cm:severity rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/severity/severity.literal.l3\"/>\n";
	}
	if($severity =~ m/60/ ){
		print XML "<oslc_cm:severity rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/severity/severity.literal.l2\"/>\n";
	}

	#%hardware
	if(lc($hardware) eq "any" ){
		print XML "<rtc_cm:hardware rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/change_hardware/hardware_any\"/>\n";
	}
	if(lc($hardware) eq "public" ){
		print XML "<rtc_cm:hardware rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/change_hardware/hardware_public\"/>\n";
	}
	if($hardware =~ m/Full/ ){
		print XML "<rtc_cm:hardware rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/change_hardware/hardware_public_full_text\"/>\n";
	}
	if($hardware =~ m/Private/ ){
		print XML "<rtc_cm:hardware rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/change_hardware/Hardware_private\"/>\n";
	}
	if($hardware =~ m/Lab/ ){
		print XML "<rtc_cm:hardware rdf:resource=\"$server_url/ccm/oslc/enumerations/_ydStIPYDEeOyjYZ6-sv7sA/change_hardware/Project_for_lab_only\"/>\n";
	}
	

	#%Internal_Tag #%keyword
	print XML "<dc:subject>$Internal_Tag $keyword</dc:subject>\n";
	
	
	
	#%Impact -> l'impact prédefinie dans RTC est: rtc_cm:com.ibm.team.workitem.workItemType.risk.impact  est-ce qu'on rutilise ou on en crée un nouvel attribut?
	
	
	
	
	#%Project -> 1 WI par projet, puis les WI concerne ce projet sera mis dans son LINK.
	if($Project){
		($prefix,$name) = split (/-/, $Project, 2);
		chomp($name);
		$name =~ s/\s/_/g;
		$name =~ s/\&/and/g;
		my $xml_get_project = "c:\\temp\\projet_$name.xml";
		$cmd = "curl.exe -k -g -b %COOKIES% https://vp-pgr-rtc.fr.mega.com:9443/ccm/rpt/repository/workitem?fields=workitem/workItem[summary='$name']/(id) > $xml_get_project";
		print $cmd;
		system($cmd);

		$xml = new XML::Simple;
		my $ref = $xml->XMLin($xml_get_project);
	
		if(defined($ref->{workItem}->{id})){
			print $ref->{workItem}->{id};
			$wi_id = $ref->{workItem}->{id};
			# si la création de WI projet réussi, on a attacher le WI qu'on était entrain de créer avec elle
			print "WI for project $name OK\n";
			print XML "<dc:subject>$Internal_Tag $keyword</dc:subject>\n";
			print XML "<rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent rdf:resource=\"$server_url/ccm/resource/itemName/com.ibm.team.workitem.WorkItem/$wi_id\"/>"; 						
		}
		else{
			# on crée le WI deprojet ici, avec un autre ficheir XML d'entrée
			print "No WI found for project: $name, on va en créer une.";
			$file_xml_projet = "c:\\temp\\projet_".$name."_wi_creation.xml";
	
			# initialisation de XML de la céation.
			open(XMLPJT,">$file_xml_projet");
			print XMLPJT "<oslc_cm:ChangeRequest
			xmlns:oslc_cm=\"http://open-services.net/xmlns/cm/1.0/\"
			xmlns:dc=\"http://purl.org/dc/terms/\"
			xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
			xmlns:calm=\"http://jazz.net/xmlns/prod/jazz/calm/1.0/\"
			xmlns:rtc_cm=\"http://jazz.net/xmlns/prod/jazz/rtc/cm/1.0/\"
			xmlns:oslc_pl=\"http://open-services.net/ns/pl#\">\n";
			
			print XMLPJT "<dc:title>$name</dc:title>\n";
			print XMLPJT "<dc:subject>Project</dc:subject>\n";
			print XMLPJT "</oslc_cm:ChangeRequest>\n";
			close XMLPJT;
			
			# création de WI de prjet
			$report_file = "c:\\temp\\projet_".$name."_wi_creation_log.xml";
			my $command_create = "curl.exe -k -b %COOKIES% -H \"Content-Type: application/x-oslc-cm-change-request+xml\" -H \"Accept: text/xml\" -X POST -d \@$file_xml_projet https://vp-pgr-rtc.fr.mega.com:9443/ccm/oslc/contexts/_ydStIPYDEeOyjYZ6-sv7sA/workitems/task  > $report_file";
			print "\n".$command_create."\n";
			system($command_create);
			
			$file_size = stat($report_file)->size;
			if($file_size < 2000){
				print "WI for project $name KO\n";
			}
			else{
				
				$ref = $xml->XMLin($report_file);
				$wi_id = $ref->{'dc:identifier'};
				print XML "<rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent rdf:resource=\"$server_url/ccm/resource/itemName/com.ibm.team.workitem.WorkItem/$wi_id\"/>";
			}	
		}			
	}
	
	
	
	
	
	
	#%Test_data__Disk
	print XML "<rtc_cm:test_data_disk>$Test_data__Disk</rtc_cm:test_data_disk>\n";
	
	#%Test_data__SQL
	print XML "<rtc_cm:test_data_sql>$Test_data__SQL</rtc_cm:test_data_sql>\n";
	#%QA_Code
	print XML "<rtc_cm:qa_code>$QA_Code</rtc_cm:qa_code>\n";
	
	#%support_number
	print XML "<rtc_cm:suppot_number>$support_number</rtc_cm:suppot_number>\n";
	
	#%ecr_number#
	print XML "<rtc_cm:ecr_code>$ecr_number</rtc_cm:ecr_code>\n";

	print XML "</oslc_cm:ChangeRequest>\n";
	
	close XML;
	
	$report_file = "c:\\temp\\$problem_number.txt";
	my $command_create = "curl.exe -k -b %COOKIES% -H \"Content-Type: application/x-oslc-cm-change-request+xml\" -H \"Accept: text/xml\" -X POST -d \@$file_xml https://vp-pgr-rtc.fr.mega.com:9443/ccm/oslc/contexts/_ydStIPYDEeOyjYZ6-sv7sA/workitems/task  > $report_file";
	print "\n".$command_create."\n";
	system($command_create);
	
	$file_size = stat($report_file)->size;
	if($file_size < 2000){
		print "[SUCCESS]création de WI for CR $problem_number KO\n";
	}
	else{
		print "[ERROR]création de WI for CR $problem_number OK\n";
	}

	
	
}
# 3 create le WI dans RTC avec la commande CURL
# 3.1 si la création echoué faut faire un rejet avec la ligen de CR
# 4 renseigner le champ ID_RTC dans Change.

ccm_stop_session();
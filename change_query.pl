

use Mega::Synergy::Sessions;





# 1 lancer un requete pour recuperer les CR qui sont arbitrée "to_be_migrate"

# lancement de session synergy
my $NewCcmAddr = ccm_start_session("modeling","cli");
if($NewCcmAddr){
    print "\nOpened\n";
} else {
    print "\nError appeared while opening a new session. Please check Synergy/CM log files or contact build management team.\n";
    exit 1;
}

# %problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%resolver#%hardware#%Internal_Tag#%keyword#%Impact#%Test_data__Disk#%Test_data__SQL#%QA_Code#%support_number#%ecr_number#

# ccm query /type problem "resolver='xyu' and release='8-0.800'" -u -f "  "
# my @CR_list = `ccm query /type problem "resolver='xyu' and release='8-0.800'" -u -f "%problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%resolver#%hardware#%Internal_Tag#%keyword#%Impact#%Test_data__Disk#%Test_data__SQL#%QA_Code#%support_number#%ecr_number#"`;
# and status='assigned' and release='8-0.800'
# my @CR_list = `ccm query /type problem "problem_number='46535'" -u -f "%problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%hardware#%Internal_Tag#%keyword#%Impact#%Test_data__Disk#%Test_data__SQL#%QA_Code#%support_number#%ecr_number#"`;
my @CR_list = `ccm query /type problem "assignment_date>time('%this_week_begin')" -u -f "%problem_number#%problem_synopsis#%enterer#%release#%resolver#%request_type#%Front_End#%Estimate#%Priotity#%severity#%hardware#%Internal_Tag#%keyword#%Impact#%QA_Code#%support_number#%ecr_number#%Project#%Test_data__Disk#%Test_data__SQL"`;

foreach $cr (@CR_list){
	
	# $cr =~ s/\n//g;
	# $cr =~ s/\r//g;
	$cr =~ s/<void>//g;
	# $cr =~ s/[^0-9A-z\.\,#]//g;
	$cr =~ s/ç/c/g;
	$cr =~ s/[éèêë]//g;
	$cr =~ s/[àâ]//g;
	$cr =~ s/[«»]/\"/g;
	print $cr;
}


ccm_stop_session();
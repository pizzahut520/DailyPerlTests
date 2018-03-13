#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================

use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::FileOp;
use Date::Calc qw(:all);
use Mega::Exploit;
use Mega::Synergy::Sessions;

####################################################
# préparation des variables.
####################################################


my $version =   $ARGV[0];
my $espace =    lc($ARGV[1]);
my $tasks_string = $ARGV[2]; # la list doit être séparé par ";"
my $projets_string = $ARGV[3]; # la list doit être séparé par ";"


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


####################################################
# controler si toutes les tâches sont completées.
####################################################
print "Analyse la liste des tâches, faut que tout les tâches dans la liste soient completée, sinon le program s'abondone.\n";
@task_list = split(/;/, $tasks_string);
foreach $task (@task_list) {
    my $task_status = `ccm task /show info /format %status $task`;
    chomp($task_status);
    if(lc($task_status) ne "completed"){
        print $task." n'est pas une tâche completée, Abandonne...\n";
        ccm_stop_session();
        exit 1;
    }
}
print "Analyse OK\n";

#####################################################################################################
# prendre les sources à partir des tasks, ainsi que les noms des projet à rebuilder
#####################################################################################################
my $versionespace = "$version.$espace";
@projet_java = `ccm query \"hierarchy_asm_members(cvtype='project' and name = 'mjava' and version ='$versionespace', 'none')\" -u -f %name`;
@projet_code =`ccm query \"hierarchy_asm_members(cvtype='project' and name = 'code' and version ='$versionespace', 'none')\" -u -f %name`;

#####################################################################################################
# prendre les sources à partir des tasks, ainsi que les noms des projet à rebuilder
#####################################################################################################

print "Cherche info tâches...\n";
my @projet_list_code=();
my @projet_list_java=();
foreach $task (@task_list){
    
    my @task_source = `ccm task /show obj $task /f \"%name;%project;%type;;%version\"`;
    foreach $Line (@task_source)
    {
        chomp($Line);
        my @array = split(/;/, $Line);
        print $Line."\n";
        if (@array[1] ne "") {
            if(grep(/@array[1]/, @projet_java)){ 
                if(!grep(/@array[1]/, @projet_list_java)){ 
                    push(@projet_list_java, @array[1]);
                }
            }else{
                if(grep(/@array[1]/, @projet_code)){ 
                    if(!grep(/@array[1]/, @projet_list_code)){ 
                        push(@projet_list_code, @array[1]);
                    }
                }
            }
        }
    }
}



@dll_list = split(/;/, $projets_string);
foreach $dll (@dll_list){
	if(!grep(/$dll/, @projet_list_code)){ 
		push(@projet_list_code, $dll);
	}
}
##############################################################################
# calcul l'ordre de build des projets. que pour les projet CPP, pour JAVA on s'en fou.
##############################################################################

# importer le fichier build_c_index.txt dans une HASH

my %hash;
open (FILE, 'w:\\tools\\build_c_index.txt');
while (<FILE>)
{
   chomp;
   my ($key, $val) = split /:/;
   $hash{$key} = $val;
}
my %hash_final;
foreach $projet (@projet_list_code){
    if(exists $hash{$projet}){
        $hash_final{$hash{$projet}} = $projet;
    }
}
my @projet_list_code=();
foreach $k (sort keys %hash_final){
    push(@projet_list_code, $hash_final{$k});
}
if(lc($espace) eq "iqa" && !grep("stdl", @projet_list_code)){                         
    push(@projet_list_code, "stdl");
}

print "les Projets CODE à rebuilder:\n";

print "Pour Visual:\n";
foreach $p (@projet_list_code){
    print $p."\n";
}

print "les Projets MJAVA à rebuilder:\n";
print "Pour Java:\n";
foreach $p (@projet_list_java){
    print 
$p."\n";
}


exit;

######################################################## 
#  remonter les tâches en question dans le folder ciblé.
######################################################## 


print "Remonter les tâches dans folder $version $espace\n";

$espace_min = lc($espace);
my $versions_ini = "w:\\tools\\versions.ini";
my $folder_target = Read_Ini($versions_ini, "$version","folder_$espace_min","");


foreach $task (@task_list){
    
        my $stask = "task$task";
        my $ret ="";
        $PgmVar = "ccm query /t task /name $stask \"is_task_in_folder_of('probtrac/folder/$folder_target/1')\"";
        # print "$PgmVar\n";
        ($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
        $ret = <PIPE>;
        close(PIPE);

         if ($ret eq "") {
            my $set_admin = "ccm set role build_mgr";
            ($pid = open(PIPE, "$set_admin |")) or die "Impossible d'exécuter : $!\n";
            while (defined($line = <PIPE>))
            {
                print "$line";
            }
            
            
            $PgmVar = "ccm folder /m /at $task $folder_target";
            print "$PgmVar\n";
            ($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
            while (defined($line = <PIPE>))
            {
                print "$line";
            }
            close(PIPE);        
            
            Modif_Log($task);
            
         }else{
            print "La tâche $task existe déjà dans le folder  $folder_target\n";
         }
}



######################################################## 
#  Build
######################################################## 
# commence par CPP
# Commence par le repertoire inc qui se trouve dans projet CODE, c'est une répertoire mais pas un projet, on le traitera différement

print "Build les projets CCM\n";

if(scalar(@projet_list_code)>0){
    print "Pour projet visual on commence par le repertoire code\\inc \n";
    my $set_admin = "ccm set role build_mgr";
    ($pid = open(PIPE, "$set_admin |")) or die "Impossible d'exécuter : $!\n";
    while (defined($line = <PIPE>))
    {
        print "$line";
    }
    
    my $reconf_inc = "X:\\wa\\code-$version.$espace\\code\\inc";
    print $reconf_inc."\n";
    
    ($pid = open(PIPE, "ccm reconf $reconf_inc /r |")) or die "Impossible d'exécuter : $!\n";
    while (defined($line = <PIPE>))
    {
        print "$line";
    }
    close(PIPE);
    
    # boucle de projets list pour les projet à reconfigurer.
    
    
    foreach $projet (@projet_list_code){
        # parametre: expcpblm.pl $espace $version $mode $compile $reconf $projet";
        $espace = lc($espace);
        $PgmVar = "w:\\tools\\expcpblm.pl $espace $version release 1 1 $projet";
        print $PgmVar."\n"; 
        
        ($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
        while (defined($line = <PIPE>))
        {
            print "$line";
        }
        close(PIPE);
    
    }
}
# boucle de projets list pour les projet à reconfigurer.
if(scalar(@projet_list_java) > 0){
    foreach $projet (@projet_list_java){
        $PgmVar = "w:\\tools\\expdev_java_proj.pl $espace $version release 1 mjava $projet";
        print $PgmVar."\n";
        
        ($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
        while (defined($line = <PIPE>))
        {
            print "$line";
        }
        close(PIPE);
    
    }
}

# fermer la session CCM
print "Fermer la session CCM\n";
ccm_stop_session();


print "\nPour Visual:\n";
foreach $p (@projet_list_code){
    print $p."\n";
}


print "\nPour Java:\n";
foreach $p (@projet_list_java){
    print $p."\n";
}



#-----------------------------------------------------------------------------------------------------
#  Modification du log de la tache
#-----------------------------------------------------------------------------------------------------
sub Modif_Log {
    my $task = shift;

    $Role1 = `ccm set role`;
    chomp($Role1);
    if ($Role1 ne "ccm_admin") {
        $PgmVar = "ccm set role ccm_admin";
        system($PgmVar);
    }

    my $sTask = "task$task-1:task:probtrac";
    ($year,$mon,$day) = Today();
    ($hour,$min,$sec) = Now();

    $tasklog = "";
    $tasklog = "$year/$mon/$day $hour:$min:$sec : Tache dans le folder " . uc($espace) . " $version par $userI";
    open(LOG,"> $TEMP\\log.txt");
    print LOG "$tasklog";
    close LOG;

    `ccm task /mod /desc \"$tasklog\" $task`;

    $PgmVar = "ccm set role $Role1";
    system($PgmVar);
}



exit 0;

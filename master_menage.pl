use File::Path;
use File::stat;
use File::Basename;
use Mega::Exploit;
use File::Copy;
use Mega::Logger;
use MIME::Lite;
use Net::SMTP;
use File::Copy;
use Carp qw(croak);





$File_Ini         = "w:/tools/versions.ini";
@L_Versions = Read_Ini_Sections($File_Ini);

if( $logfile eq "" ) {
  $logfile = $ENV{TEMP} . "\\master_menage$$.log";
}
my $Logger = new Mega::Logger;
$Logger->open($logfile);
$Logger->set_prefix('#date#');
$Logger->log(join (' ', "$0", @ARGV, "\n", "\n"));



$Logger->log_print("##########start cleaning the MASTER directories for saving space in W:\\...\n");

my $master_poubelle = "W:\\temp\\master_trash";
# menage sur w:\
foreach $version (@L_Versions){
	
	$Logger->log_print( "\nversion = $version\n");
	my $bIncrmt = Read_Ini($File_Ini, "$version","buildincrement","");
	my $master_path = "w:\\$version\\master";
	if(chdir($master_path)){
		opendir my $dh, $master_path or die "$0: opendir: $!";		
		my @dirs = grep {-d "$master_path/$_" && ! /^\.{1,2}$/} readdir($dh);
		
		foreach $dir (@dirs){
			$Logger->log_print("   ".$master_path."\\".$dir."\n");			
			opendir my $dh, $dir or die "$0: opendir: $!";					
			my @dirs_master = grep {-d "$dir/$_" && ! /^\.{1,2}$/} readdir($dh);
			$nbr_master = scalar @dirs_master;
			
				foreach $d (@dirs_master){
											
					$Logger->log_print("         ".$d."\n");
					# $bIncrmt
					if ($nbr_master eq 1){
						$Logger->log_print("                               in the directory $master_path\\$dir there's only one master, let's keep it\n");
						next;
					}
					if($d =~ /[a-zA-Z]/){
						$Logger->log_print("                               $d, i dont know what it is\n");
						next;
					}
					my $delta = $bIncrmt-$d;
					if( $delta> 5 && $nbr_master>5){
						$Logger->log_print("                               $d is an old master, let's delete it.\n");
						# rmtree($master_path."\\".$dir."\\".$d);
						$nbr_master -= 1;
					}
				}
		}	
	}else{
		$Logger->log_print("No Master folder found for this version, Next\n\n");
		next;
	}	
}


$Logger->log_print( "##########start cleaning the RDBMS directories for saving space in W:\\...\n");
my $rdbms_path = "w:\\RDBMS";
opendir my $dh, $rdbms_path or die "$0: opendir: $!";		
my @dirs = grep {-d "$rdbms_path/$_" && ! /^\.{1,2}$/} readdir($dh);
		
foreach $rdbms_dir (@dirs){
		$Logger->log_print($rdbms_dir."\n");	
		
		my $bIncrmt = Read_Ini($File_Ini, "770","buildincrement","");
		if(chdir($rdbms_path."\\".$rdbms_dir)){
			$Logger->log_print("   ".$rdbms_path."\\".$rdbms_dir."\n");	
			
			opendir my $dh, $rdbms_path."\\".$rdbms_dir or die "$0: opendir: $!";		
			my @builds = grep {-d "$rdbms_path/$rdbms_dir/$_" && ! /^\.{1,2}$/} readdir($dh);
			$nbr_bkp = scalar @builds;
			
			foreach $build (@builds){
				my @d = split("_", $build);
				$nb = $d[1];
				$Logger->log_print("         ".$nb ."\n");
				my $delta = $bIncrmt-$nb;
			
					if ($nbr_bkp eq 1){
						$Logger->log_print("                               in the directory $rdbms_path\\$rdbms_dir there's only one backup, let's keep it\n");
						next;
					}
					if($d =~ /[a-zA-Z]/){
						$Logger->log_print("                               $build, i dont know what it is\n");
						next;
					}
					
					if( $delta> 5 && $nbr_bkp>4){
						$Logger->log_print("                               $build is an old backup, let's delete it.  rmtree($rdbms_path\\$rdbms_dir\\$build)\n");
						rmtree($rdbms_path."\\".$rdbms_dir."\\".$build);
						$nbr_bkp -= 1;
					}
				}
				
			}
			
}
		














Send_mail($logfile);


sub Send_mail {

  my $mFileLog   = shift;


  my $texte  = "";
  my $addrto = "exploitation";
  my $sujet = "";
  my $attach = "";

  $sujet = "menage des master";
  $texte  = "pour economiser d'espace dans w:\\ \nles masters à supprimer sont deplacer dans W:\\temp\\master_trash\n  verifie qu'on n'a pas supprimé trop de chose et faire la vraie suppression à la main";

  $attach = "$mFileLog";
  my $filename = basename($attach);

  my $Message = new MIME::Lite 
  From =>'xyu@mega.com', 
  To =>'xyu@mega.com,hgilbert@mega.com,hlefevre@mega.com', 
   # ,hgilbert@mega.com,hlefevre@mega.com
  Subject =>$sujet,
  Type =>'multipart/mixed'; 
  # Ajoutez le message (texte ou html)
  attach $Message 
    Type =>'TEXT', Data =>"$texte";

  # Ajoutez un document log
  attach $Message 
    Type =>'application/log',Path =>$attach,Filename =>$filename; 

  my $user="exp2";
  my $pass="exp06";
  MIME::Lite->send('smtp', 'exa.fr.mega.com', AuthUser=>$user, AuthPass=>$pass);
 
  $Message->send('smtp', 'exa.fr.mega.com', Timeout=>60, Hello=>'mega.com');
}







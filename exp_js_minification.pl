#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================


use Win32::Api;
use Getopt::Long;
use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
use Win32::File;
use Win32::FileOp;
use File::DosGlob 'glob';
use File::Basename;
use File::Path;
use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );
use Mega::Logger;
use Mega::Exploit;
use MIME::Lite;
use Net::SMTP;

#=====================================================================================================
#                           PARAMETERS
#=====================================================================================================

my $Espace     = shift;
my $Version    = shift;
my $PrivMaster		 = shift;
my $FlagEndTrt = shift;


$File_Ini = "w:/tools/Versions.ini";

$PathBldEnv       =  Read_Ini($File_Ini, "$Version","PathBldEnv","");
$PathBldEnvSystem = "$PathBldEnv\\System";

my $ErrorFile;
my $WindowsTitle = "\"Compilation $Version $Espace\"";

$Project="code";
$projet=$Project . "-" . $Version . "." . $Espace;
$WA_PATH="x:\\wa\\$projet";
$PROJ_PATH = $WA_PATH . "\\code";


if( $logfile eq "" ) {
    $logfile = $ENV{TEMP} . "\\JS_minification_$$.log";
}
Flag_WriteFile($FlagEndTrt, "MinificationJava", $logfile);

my $Logger = new Mega::Logger;
$Logger->open($logfile);
$Logger->set_prefix('#date#');
$Logger->log(join (' ', "$0", @ARGV, "\n", "\n"));

my $PathTarget      = Read_Ini($File_Ini, "$Version","PathTarget","");     # OK
my $PathFournitures = Read_Ini($File_Ini, "$Version","PathDemo","");       # OK
if(lc($Espace) eq "tst"){
	$PathFournitures = $PathFournitures.".tst";
}
my $PathTargetHopex = "$PathTarget\\Hopex";

if(lc($Espace) eq "tst" || lc($Espace) eq "int"){

	if ($Version >= "730") {
		$Logger->log_print("Minification Hopex");
		minification_js("dtpx");
		$Logger->log_print("Minification Advisor");
		minification_js("advr");
		# xyu copie des source extjx_ux minifié
		my $path_extjs_dest = $PathTargetHopex."\\script\\mega";
		my $path_extjs_origine = $PathFournitures."\\javascript\\extjsDTPX\\extjs_exploit";
		opendir(DIR, "$path_extjs_origine");
		my @FILES= readdir(DIR);
		my $extjs_ver = $FILES[2];
		$path_extjs_origine = $path_extjs_origine."\\".$extjs_ver;
		print "path_extjs_origine = $path_extjs_origine";
		CopyEx("$path_extjs_origine\\extjs_ux.*" => "$path_extjs_dest",FOF_FILESONLY|FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION) or warn "$!";
	}
}

sub minification_js{
        
        my $projet_ccm = shift;
        my $projet_mega = "";
        my $projet_dir = "";
		
        if($projet_ccm eq "dtpx"){
              $projet_mega = "hopex";
              $projet_dir = "dtpx";
			  
        }
        if($projet_ccm eq "advr"){
              $projet_mega = "advisor";
              $projet_dir = $projet_ccm."\\mega advisor\\dotnet";
        }
		$Logger->log_print("projet = $projet_ccm \n");
		print "projet = $projet_ccm \n";
        my $PathOrigineVersion = $WA_PATH;
        my $path_origine = $PathOrigineVersion."\\code\\$projet_dir";
        print "path_origine = $path_origine \n";
		$Logger->log_print("path_origine = $path_origine \n");
        # PathTarget = installCode
        my $PathTarget = $PathTarget."\\$projet_mega";
        print "PathTarget = $PathTarget \n";
		$Logger->log_print("PathTarget = $PathTarget \n");
        my $target_minification = "";
        
        if($projet_ccm eq "dtpx"){
            $target_minification = $PathTarget."\\script\\mega";
        }
        if($projet_ccm eq "advr"){
            $target_minification = $PathTarget."\\mega";
             
        }

        if (chdir("$PathTarget")) {
            Mega_del_tree("$PathTarget");
        }
        print   "$path_origine\\\\*\" => \"$PathTarget";
		$Logger->log_print("$path_origine\\\\*\" => \"$PathTarget");
		
	    CopyEx("$path_origine\\*" => "$PathTarget",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
        print "target_minification = $target_minification \n";
		$Logger->log_print("target_minification = $target_minification \n");
        my $source_map = $target_minification."\\mega_all.map";
        my $file_out_put = $target_minification."\\mega_all.js";
        my $minification_tool = "w:\\tools\\compiler.jar";
        $file_input = $PathOrigineVersion."\\code\\_exp\\js_minification_list_".$projet_mega.".txt";
        

        my $file_list = "";

        open (INPUT, $file_input) or die "cannnot open the input file $file_input";
            while(my $line = <INPUT>){
            chomp($line);
			my $dirname = "";
	        if($projet_ccm eq "dtpx"){ $dirname = $path_origine."\\script\\mega";}
			if($projet_ccm eq "advr"){ $dirname = $path_origine."\\mega";}
			
			if(-f $dirname."\\".$line) {
				$file_list = $file_list." .\\".$line;
			} else {
				$Logger->log_print("The file \"".$dirname."\\".$line."\" does not exist\n");	
			}
        }


        $ENV{'JAVA_HOME'} = "W:\\sdk\\jdk1.7.0_07";
		$Logger->log_print("$ENV{'JAVA_HOME'}\n");	
        my $Java_Home = $ENV{'JAVA_HOME'};
        my $log_minif = "w:\\temp\\minif_$projet_mega.txt";
 


        my $command = $Java_Home."\\bin\\java.exe -jar ".$minification_tool." --js $file_list  --js_output_file $file_out_put --create_source_map $source_map --source_map_format=V3 1>$log_minif 2>&1";
        open (COMM,">c:\\temp\\command.txt");
        print COMM $command;
        close (COMM);   
      
        my $minif_dest = Read_Ini($File_Ini, "$Version","pathdemo","");  
        $minif_dest =  $minif_dest."\\Minification\\$projet_mega";

		my $minif_war_pattern = ": WARNING";
        my $minif_err_pattern = ": ERROR";
        open( MINIFLOG ,$log_minif);
        my @buf = <MINIFLOG>;
        
        if(grep (/$minif_err_pattern/,@buf) || grep (/$minif_war_pattern/,@buf)){
            Send_mail_minification( $Version, $Espace, $log_minif, $projet_mega);
        }
        close (MINIFLOG);   
        if (chdir("$target_minification")) {
            
            open $fpipe, "-|", "$command";
                while ( <$fpipe> ) { 
                    $Logger->log_print($_);
                };
                close ($fpipe);
                open (CONT,">>$file_out_put");
                print CONT "\n//\@ sourceMappingURL=mega_all.map";			
                close (CONT);       
            close (INPUT);
                    
            open (INPUT, $file_input) or die "cannnot open the input file $file_input";
			
			
			if ($Version >= "740" and $PrivMaster eq "Commercial_CD") {
			print "\n deleting the Js files non minified \n";
			$Logger->log_print("\n deleting the Js files non minified \n");	
				while(my $line = <INPUT>){
				chomp($line);
					
					unlink($line);
					print "\n$line deleted";
				}
			}
        }
		

		
}


sub Send_mail_minification {

    my $version = shift;
    my $espace = shift;
    my $mFileLog   = shift;
    my $projet = shift;

    my $texte  = "";
    my $addrto = "exploitation";
    my $sujet = "";
    my $attach = "";

    $sujet = "[$version $espace Minification $projet] Erreur ou Warning";
    $texte  = "";

    $attach = "$mFileLog";
    my $filename = basename($attach);

    my $Message = new MIME::Lite 
    From =>'exploitation@mega.com', 
    To =>'exploitation@mega.com,xyu@mega.com,flevy@mega.com,atauveron@mega.com,scanonica@mega.com,nlavallee@mega.com,hgilbert@mega.com,jyleloup@mega.com', 
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

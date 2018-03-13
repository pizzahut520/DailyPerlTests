
$version = 750;
$espace = "pro";
$projet_ccm = "dtpx";
my $minification_tool = "w:\\tools\\minification.jar";
print "\n#INFO: For Peojext HOPEX we will pre minify the source extjs which are not minified";
my $list_ux = "X:\\wa\\code-$version.$espace\\code\\_exp\\js_minification_ux_list_hopex.txt";
my $path_origine = "X:\\wa\\code-$version.$espace\\code\\$projet_ccm";
print "\n#INFO: the file = $list_ux";

my $tst = "";
if($espace eq "TST"){
	$tst = ".tst";
}
my $mini_path = "W:\\$version\\Fournitures".$tst."\\javascript\\extjsDTPX\\extjs_exploit";
opendir(DIR, "$mini_path");
@FILES= readdir(DIR);
my $extjs_ver = $FILES[2];
$mini_path = $mini_path."\\".$extjs_ver;

my $file_out_put = $mini_path."\\extjs_ux.js";
my $source_map = $mini_path."\\extjs_ux.map";

print "\n#INFO: the input file = $list_ux";
print "\n#INFO: the minify Path = $mini_path";




close (INPUT);	
$ENV{'JAVA_HOME'} = "W:\\sdk\\jdk1.7.0_07";
# print "$ENV{'JAVA_HOME'}";
my $Java_Home = $ENV{'JAVA_HOME'};
my $log_minif = $mini_path."\\minif_$projet_mega.txt";
my $command = $Java_Home."\\bin\\java.exe -jar ".$minification_tool."  $list_ux  $file_out_put  $source_map  1>$log_minif 2>&1";
print "\n#INFO: minifying extjs source... \n";
print "\n#INFO: fichier de sortie : $file_out_put... \n";

if (chdir("$mini_path")) {	
	 
	system($command);			
	open (CONT, ">>$file_out_put") or die "cannnot open the input file $file_out_put";
	print CONT "\n//# sourceMappingURL=mega_all.map";
	close (CONT); 
}




use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );


$zip_instance = Archive::Zip->new();
@projet_list_code = ("mapp","stdl","gbmm");
@projet_list_java = ("api","wfeng");

$version = "750";
$espace = "int";
$zip_file = "W:\\$version\\HotFix_preparation\\HOTFIX_$version.zip";

print "\nPour Visual:\n";
my $dll_chemin = "X:\\wa\\code-$version.$espace\\code\\ExeRelease_Win32";
foreach $p (@projet_list_code){
    print "rajout de fichier mg_$p.dll\n";
	$file = $dll_chemin."\\mg_$p.dll";
	my $file_member1 = $zip_instance->addFile($file);

	if(lc($p) eq "mapp"){
		my $file_member2 = $zip_instance->addFile($dll_chemin."\\mgwmapp.exe");
		my $file_member3 = $zip_instance->addFile($dll_chemin."\\mgwspro.exe");		
		my $file_member3 = $zip_instance->addFile($dll_chemin."\\mgwssp.exe");
	}
	if(lc($p) eq "stdl"){
		my $file_member4 = $zip_instance->addFile($dll_chemin."\\mg_dico.dll");
	}
}

#ajout
print "\nPour Java:\n";
my $dll_chemin = "X:\\wa\\mjava-$version.$espace\\mjava\\ExeRelease";
foreach $p (@projet_list_java){
    print "rajout de fichier mj_$p.jar\n";
	$file = $dll_chemin."\\mj_$p.jar";
	my $file_member3 = $zip_instance->addFile($file);
	
	$file = $dll_chemin."\\mj_$p.doc.zip";
	if(-f $file){
		$file_member3 = $zip_instance->addFile($file);
	}
}
#minification#



#génération du zip release
unless ( $zip_instance->writeToFileNamed($zip_file) == AZ_OK ) {
       die 'write error';
}

exit;
#pdb#
$zip_instance = Archive::Zip->new();
$zip_file_pdb = "W:\\$version\\HotFix_preparation\\HOTFIX_$version_$buildincrement_pdb.zip";
if(-f $zip_file_pdb){
    unlink $zip_file_pdb;
}



foreach $p (@projet_list_code){
    print "rajout de fichier mg_$p.pdb\n";
	$file = $dll_chemin."\\mg_$p.pdb";
	my $file_member1 = $zip_instance->addFile($file);

	if(lc($p) eq "mapp"){
		$file_member2 = $zip_instance->addFile($dll_chemin."\\mgwmapp.pdb");
		$file_member3 = $zip_instance->addFile($dll_chemin."\\mgwspro.pdb");		
		$file_member4 = $zip_instance->addFile($dll_chemin."\\mgwssp.pdb");		
	}
	if(lc($p) eq "stdl"){
		$file_member5 = $zip_instance->addFile($dll_chemin."\\mg_dico.pdb");
	}
}

unless ( $zip_instance->writeToFileNamed($zip_file_pdb) == AZ_OK ) {
       die 'write error';
}


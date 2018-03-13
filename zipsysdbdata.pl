use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );

my $zip_file = "$dir_sql\\".$Version.$Espace."_".$BIncrement."\\rdbms_".$Version.$Espace.".zip";
if(! -d $dir_sql."\\".$Version.$Espace."_".$BIncrement){
	mkdir $dir_sql."\\".$Version.$Espace."_".$BIncrement;
}
if(-f $zip_file){
    unlink $zip_file;
}

my $zip_instance = Archive::Zip->new();
print "#INFO : Preparing zip file, zip name = $zip_file\n";
if(chdir($dir)){
    @files = glob  "*.bak";
    foreach $file (@files) {
        if($file ne "." && $file ne ".."){
            print "#INFO : add file to zip, file = $file\n";
            my $file_member = $zip_instance->addFile($file);
        }   
    }
}
print "#INFO : Finalisation zip file, zip name = $zip_file\n";
unless ( $zip_instance->writeToFileNamed($zip_file) == AZ_OK ) {
       die 'write error';
}
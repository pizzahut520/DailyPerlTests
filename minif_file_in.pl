
use Win32::File;
use Win32::FileOp;
use File::Copy;
use File::Path;

# my $dtpx_origine = "$PathOrigineVersion\\code\\dtpx";
my $dtpx_origine = "x:\\wa\\code-731.int\\code\\dtpx";
my $PathTargetDtpx = "w:\\731\\InstallCode\\Hopex";
my $target_minification = $PathTargetDtpx."\\script";
$source_map = $PathTargetDtpx."\\script\\mega\\mega_all.map";
$minification_tool = "w:\\tools\\compiler.jar";
$file_input = "W:\\tools\\tmp\\minifyjs.txt";
$file_out_put = $PathTargetDtpx."\\script\\mega\\mega_all.js";
$file_list = "";

open (INPUT, $file_input) or die "cannnot open the input file $file_input";
while(my $line = <INPUT>){
	chomp($line);
	$file_list = $file_list." .\\".$line;
}

if (chdir("$PathTargetDtpx")) {
	rmtree("$PathTargetDtpx\\", { keep_root => 1 });
}
CopyEx("$dtpx_origine\\*" => "$PathTargetDtpx",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);


$command = "java -jar ".$minification_tool." --js $file_list  --js_output_file $file_out_put --create_source_map $source_map --source_map_format=V3";
print $command;

if (chdir("$target_minification")) {
	# $command =~ s/(w:\\731\\InstallCode\\Hopex\\script\\mega\\)/\.\\/g;
	# print "\n\n\n\n".$command;
	
	system($command);
}

$command_file = "c:\temp\command_file.txt";




# java -jar compiler.jar --js hello.js --js_output_file hello-compiled.js 

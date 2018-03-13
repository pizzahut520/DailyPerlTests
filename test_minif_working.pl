
use Win32::File;
use Win32::FileOp;
use File::Copy;
use File::Path;

# my $dtpx_origine = "$PathOrigineVersion\\code\\dtpx";
my $dtpx_origine = "x:\\wa\\code-731.int\\code\\dtpx";
my $PathTargetDtpx = "w:\\731\\InstallCode\\Hopex";
my $target_minification = $PathTargetDtpx."\\script\\mega";
$minification_tool = "w:\\tools\\compiler.jar";
$file_out_put = $PathTargetDtpx."\\script\\mega\\mega_all.js";
$source_map = $PathTargetDtpx."\\script\\mega\\mega_all.map";

$file_list = "";
if (chdir("$PathTargetDtpx")) {
	rmtree("$PathTargetDtpx\\", { keep_root => 1 });
}
CopyEx("$dtpx_origine\\*" => "$PathTargetDtpx",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);

minifier_dir("$target_minification");


sub minifier_dir {
	my $path = shift;
	# open path or die
	opendir my($dir), $path	
		or die "Can't open $path : $!\n";				
	 
	print "I am here: $path\n";

	# get directory content but skip . and .. (to avoid circular looping)
	my @content = grep {$_ !~ /^\.\.?$/} readdir $dir;
	# print directory name and exit if empty
	if (!@content || $path =~ /(lang)$/) {
		# print "$path  is empty\n";
		return;
	}
	foreach my $subpath (grep { -f "$path/$_"} @content) {
		if($subpath =~ /(\.js)/ || $subpath eq "analysis" ){
			# print $path.'\\'.$subpath." is a js file\n";
			my $file_origine = $path.'\\'.$subpath;
			$file_list = $file_list." ".$file_origine;
		}
	}
	# recurse trough directories
	foreach my $subpath (grep { -d "$path/$_"} @content) {
		minifier_dir($path.'\\'.$subpath);
	}
}
$command = $minification_tool." --js $file_list ";


if (chdir("$target_minification")) {
	$command =~ s/(w:\\731\\InstallCode\\Hopex\\script\\mega\\)/\.\\/g;
	$command = $command." --js_output_file $file_out_put --create_source_map $source_map --source_map_format=V3 ";
	system($command);
	print "\n\n".$command;
}

	print "\n\n".$command;



# java -jar compiler.jar --js hello.js --js_output_file hello-compiled.js 

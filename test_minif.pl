
use Win32::File;
use Win32::FileOp;
use File::Copy;
use File::Path;

# my $dtpx_origine = "$PathOrigineVersion\\code\\dtpx";
my $dtpx_origine = "x:\\wa\\code-730.int\\code\\dtpx";
my $PathTargetDtpx = "w:\\730\\InstallCode\\Hopex";
if (chdir("$PathTargetDtpx")) {
	rmtree("$PathTargetDtpx\\", { keep_root => 1 });
}
CopyEx("$dtpx_origine\\*" => "$PathTargetDtpx",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
$minification_tool = "w:\\tools\\compiler.jar";


minifier_dir("$PathTargetDtpx");

sub minifier_dir {
	my $path = shift;
	# open path or die
	opendir my($dir), $path	
		or die "Can't open $path : $!\n";				
	 
	print "I am here: $path\n";

	# get directory content but skip . and .. (to avoid circular looping)
	my @content = grep {$_ !~ /^\.\.?$/} readdir $dir;
	# print directory name and exit if empty
	if (!@content) {
		print "$path  is empty\n";
		return;
	}
	foreach my $subpath (grep { -f "$path/$_"} @content) {
		if($subpath =~ /(\.js)/){
			# print $path.'\\'.$subpath." is a js file\n";
			my $file_origine = $path.'\\'.$subpath;
			my $file_duplicate = $path.'\\dup_'.$subpath;
			print "\n".$file_origine;
			print "\n".$file_duplicate;
			if(-f $file_duplicate){
				unlink($file_duplicate);
			}
			print "\n";
			copy($file_origine, $file_duplicate) or die "File cannot be copied.";
			unlink($file_origine);
			# "java -jar ".
			$command = $minification_tool." --js $file_duplicate --js_output_file $file_origine";
			system($command);
			unlink($file_duplicate);
			# java -jar compiler.jar --js hello.js --js_output_file hello-compiled.js
		}
		
	}
	# recurse trough directories
	foreach my $subpath (grep { -d "$path/$_"} @content) {
		minifier_dir($path.'/'.$subpath);
	}
}
 

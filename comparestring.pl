

my $Espace="int";
my $Version="785";
#=======================================================
#============    Préparation d'UAS      ================
#=======================================================
my $uas_input = "W:\\INPUT_HIP\\$Espace";

my @zips = glob "$uas_input\\*.zip";

# print @zips;

my $WinzipExe = "wzunzip.exe";

my $unzip_path_common = "W:\\$Version\\Fournitures.$Espace\\UAS";
my %to_unzip;
foreach my $zip (@zips){
	
	if ($zip =~ /Macro\-core/){		
		getIn(\%to_unzip,"Macro-Core",$zip);
		 
	}
	
	if ($zip =~ /HOPEXAPI/){
		getIn(\%to_unzip,"HOPEXAPI",$zip);
		 
	}
	if ($zip =~ /HopexTemplate/){
		getIn(\%to_unzip,"HopexTemplate",$zip);
	}

	if ($zip =~ /Macro\-Function/){
		getIn(\%to_unzip,"Macro-Function",$zip);
	}
	if ($zip =~ /UAS/){
		getIn(\%to_unzip,"UAS_IIS",$zip);
	}
	if ($zip =~ /WindowsAuthenticationService/){
		getIn(\%to_unzip,"WindowsAuthenticationService",$zip);
	}
	
}

foreach my $k (keys(%hushREF)) {
		# print "Clef=$k Valeur=$hushREF{$k}\n";
		# $Logger->log_print( "Decompression de $hushREF{$k} vers $unzip_path \n");
		my $unzip_path= $unzip_path_common . "\\$k";
		print "Decompression de $hushREF{$k} vers $unzip_path \n";
		system("$WinzipExe -o -d $hushREF{$k} $unzip_path");
	
}

	
		
sub getIn{
	$hushREF = shift;
	
	$key = shift;
	$value_to_check = shift;
	
	my $file_name  = substr $value_to_check, 0, -4;  
	# print $file_name."\n";
	my @split1 = split("-",$file_name);
	$length = scalar(@split1);
	$date_input = $split1[$length-1];
	
	
	my $file_in_hush = $hushREF{$key};
	my $file_name = substr $file_in_hush, 0 , -4;
	
	my @split2 = split("-",$file_in_hush);
	$length1 = scalar(@split2);
	$date_in_hash = $split2[$length1-1];
	
	if($file_in_hush eq "" || $date_input gt $date_in_hash){
		$hushREF{$key} = $value_to_check;
		
	}

	
}






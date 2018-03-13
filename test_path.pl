# use Mega::Logger;
use Mega::PatchIni;
use Mega::Exploit;
use Win32::File;
use Win32::FileOp;


my $version_ini = "w:/tools/versions.ini";
# msp_dest_path = \\ntas\public\DailyBuild\Mega Modeling
my $ProductNameX = "$ProductName";
if ( defined  $ProductVersion and ($ProductVersion ne "")) {
    $ProductNameX = "$ProductName $ProductVersion";
}

	# \\ntas\public\DailyBuild\Mega Modeling\MEGA HOPEX V1R2 CP06 (tst Build) mega_msi_2012\750-4106
	


	my $Master = "mega_msi_2012";
	# msp_dest_path = \\ntas\public\DailyBuild\Mega Modeling
	my $PathIntegr     = Read_Ini($version_ini, "$version","PathIntegr",""); # OK
	my $ProductName    = Read_Ini($version_ini, "$version","ProductName",""); # OK
	my $productversiontst = Read_Ini($version_ini, "$version","productversiontst",""); # OK
	my $VersionMega    = Read_Ini($version_ini, "$version","VersionMega",""); # OK
	my $bIncrmt = Read_Ini($version_ini, "$version","buildincrement","");
	
	my $ProductNameX = "$ProductName";
	if ( defined  $productversiontst and ($productversiontst ne "")) {
		$ProductNameX = "$ProductName $productversiontst";
	}

	my $PathCpyIntegr = "$PathIntegr\\$ProductNameX (tst Build) mega_msi_2012\\$VersionMega-$bIncrmt\\";

	# print $PathCpyIntegr;
	
	my $patch_dir_name = Read_Ini($File_Ini, "$version","file_patch","");
	my $produit_name = Read_Ini($File_Ini, "$version","product_name","");
	my $next_patch = Read_Ini($File_Ini, "$version","next_patch","");
	
	
	my $msp_origine = $dir_patch."\\".$patch_dir_name."\\"."$produit_name $next_patch\\patch";
	

	$msp_origine = "w:\\750\\PatchBuild\\Patch MEGA Hopex 1.2\\MEGA HOPEX V1R2 Patch 6\\patch";
	$PathCpyIntegr ="r:\\DailyBuild\\Mega Modeling\\MEGA HOPEX V1R2 CP06 (tst Build) mega_msi_2012\\750-4107";
	
	print "Copy File from \n$msp_origine\n to\n $PathCpyIntegr\n";
	print LOG "Copy File from \n$msp_origine\n to\n $PathCpyIntegr\n";

	CopyEx("$msp_origine\\*.exe" => "$PathCpyIntegr",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);

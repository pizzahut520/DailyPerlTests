$version = 751;
$espace = "int";

if( $version eq 751 && lc($espace) eq "int"){
		# my $mega_site_ini = "$InstallDest\\cfg\\megasite.ini";
		my $mega_site_ini = "c:\\megasite.ini";
		my $line_to_delete = "MegaCurrentVersion=30208";
		
		open( FILE, "<$mega_site_ini" );
		@LINES = <FILE>;
		close(FILE);
	
		open( FILE, ">$mega_site_ini" );
		foreach $LINE (@LINES) {
			print FILE $LINE unless ( $LINE =~ /$line_to_delete/ );
		}
		close(FILE);
	}
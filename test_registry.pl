use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );



my $EnvKey= $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/MEGA/InstallShieldX/PathVariables"} or $Logger->fail("impossible d'ouvrir la registry\n");

while( my( $key, $val ) = each %{$EnvKey} ) {
        print "$key\t=>$val\n";
    }
	
	
	
$EnvKey->{"/PATH_TO_CCMFILES"}    = ["coucoucouc", 'REG_SZ'];
print "\n\n";

while( my( $key, $val ) = each %{$EnvKey} ) {
        print "$key\t=>$val\n";
    }
	
    use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
  my $Path_Vs = $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/MSBuild/14.0/MSBuildOverrideTasksPath"};
  print "\nPath_vs=$Path_Vs";
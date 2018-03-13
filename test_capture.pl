
my $line = "0 Error(s)";
$status_pj = "";
     

      if($line =~ m/Error\(s\)/){
      
        if($line ne "0 Error(s)") {
          $status_pj = "Ko";
        } 
        
        
      }else{
        $status_pj = "ok";
      }
      
      
      print $status_pj;
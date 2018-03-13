
use Mega::Exploit;
use Mega::Synergy::Sessions;



$versions_ini= "w:/tools/versions.ini";
@versions = Read_Ini_Sections($versions_ini);

$projet_ini = "w:/tools/sencha_ext.ini";
@projets = Read_Ini_Sections($projet_ini);

@espaces = ("dev","int","tst","iqa");

foreach $version(@versions){
    
    $wa_path = Read_Ini($versions_ini, "$version","pathorigine",""); 
    foreach $espace(@espaces){
        
        foreach $projet(@projets){
            $espace_wa_path = $wa_path."\\code-".$version.".".$espace."\\code\\".$projet;
            if(chdir($espace_wa_path)){
              $sencha_path = Read_Ini($projet_ini, "$projet","senchaPath",""); 
              if(chdir($sencha_path)){
                print $espace_wa_path."  ".$sencha_path."\n";
                
                $res = `mklink /j ext F:\\ccmdev\\sdk\\Extjs\\ext-6.2.1-light`;
                
                exit;
              }else{
                next;
              }
            
            }else{
              next;
            }
            
        }
    }

}







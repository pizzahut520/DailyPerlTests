#=====================================================================================================
#							INCLUDED MODULES
#=====================================================================================================

use Win32::GUI();
use Win32::GUI::Grid;
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::File;
use Win32::FileOp;
use Date::Calc qw(:all);
use Mega::Exploit;



#=====================================================================================================
#							PARAMETERS
#=====================================================================================================


my $File_Ini = "w:/tools/versions.ini";
@releases = Read_Ini_Sections($File_Ini);

my $trtIniFile = "W:\\tools\\Trt.ini";

my @espace = ("INT", "TST", "IQA" , "TCH");

print "\n#INFO: Operation Starting";	



#=====================================================================================================
#							MAIN WINDOW
#=====================================================================================================

my $I = new Win32::GUI::Icon("exploit.ico");
my $WC = new Win32::GUI::Class(
    -name => "Mega win32_gui", 
    -icon => $I,
);

my $Window = new Win32::GUI::DialogBox(
    -name   => "Window",
    -left   => 100, 
    -class  => $WC,
    -top    => 100,
    -width  => 400, 
    -height => 240,
    -text   => "Quick Build with Tasks",
	-resizable => 0,
	-sysmenu => 1,
    -minimizebox => 1,
    -maximizebox => 0,
);


#=====================================================================================================
#							TextField  "TASK LIST"
#=====================================================================================================

my $TASK_LIST_LABEL = $Window->AddLabel(
    -text   => "Input Task List",
    -left   => 10,
    -top    => 10,
);

$task_list_input = $Window->AddTextfield(
       -text    => "",
       -name    => "task_list",
       -left    => 40,
       -top     => 30,
       -multiline => 1,
       -width   => 300,
       -height  => 60,
      );


#=====================================================================================================
#							Text champs DLL
#=====================================================================================================
	
my $PROJETS_LABEL = $Window->AddLabel(
    -text   => "(Optionnel) JE veux builder les projets VISUAL en plus:",
    -left   => 10,
    -top    => 102,
);

my $projet_list_input = $Window->AddTextfield(
		-text    => "",
		-name    => "Projets",
		-left   => 270, 
		-top    => 100,
		-width  => 80, 
		-height => 20,
      );
	  
	  
	  
#=====================================================================================================
#							COMBOBOX "VERSION"
#=====================================================================================================
	
my $VERSION_LABEL = $Window->AddLabel(
    -text   => "Version",
    -left   => 10,
    -top    => 132,
);

my $CBrelease = $Window->AddCombobox( 
    -name   => "CbRelease",
    -left   => 50, 
    -top    => 130,
    -width  => 80, 
    -height => 100,
	-vscroll => 1,
	-tabstop => 1,
	-dropdown => 1,
);



foreach $l_version (@releases) {
    $CBrelease->InsertItem("$l_version");
}
$CBrelease->Select(0);



#=====================================================================================================
#							COMBOBOX "Espace"
#=====================================================================================================
	
my $ESPACE_LABEL = $Window->AddLabel(
    -text   => "Espace",
    -left   => 150,
    -top    => 132,
);

my $CBespace = $Window->AddCombobox( 
    -name   => "CbEspace",
    -left   => 190, 
    -top    => 130,
    -width  => 80, 
    -height => 100,
	-vscroll => 1,
	-tabstop => 1,
	-dropdown => 1,
);



foreach $l_espace (@espace) {
    $CBespace->InsertItem("$l_espace");
}
$CBespace->Select(0);





my $OK = $Window->AddButton( 
	-name => "OK",
	-top => 160,  
	-left => 200, 
	-height => 35,     
	-width => 80, 
	-default => 1, 
	-ok => 1,   
	-text => "GO",     
	-tabstop => 1,
);

my $Cancel = $Window->AddButton( 
	-name => "Cancel", 
    -top => 160,  
	-left => 300, 
	-height => 35,  
	-width => 80, 
	-cancel => 1,  
	-text => "Cancel",  
	-tabstop => 1,
);



#=====================================================================================================
#							PROCESSING
#=====================================================================================================

$Window->Show;
Win32::GUI::Dialog;


sub Window_Terminate {
    return -1;
}

sub Cancel_Click {
    return -1;
}


sub OK_Click {

	#checking inputs 
	
	my $version = $CBrelease->GetString($CBrelease->SelectedItem);
	my $espace = $CBespace->GetString($CBespace->SelectedItem);
	my $task_list = $task_list_input->Text;
	my $projet_list = $projet_list_input->Text;
	
	print $version." ".$espace." ".$task_list;
	$PgmVar = "w:\\tools\\task_Patch.pl $version $espace $task_list $projet_list";
        system($PgmVar);
	
}











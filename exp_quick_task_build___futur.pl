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

my $trtIniFile = "W:\\tools\\Trt.ini";

my @releases = Read_Ini_Parameters($trtIniFile, "versioncopy");
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
    -height => 440,
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
#							COMBOBOX "VERSION"
#=====================================================================================================
	
my $VERSION_LABEL = $Window->AddLabel(
    -text   => "Version",
    -left   => 10,
    -top    => 102,
);

my $CBrelease = $Window->AddCombobox( 
    -name   => "CbRelease",
    -left   => 50, 
    -top    => 100,
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
    -top    => 102,
);

my $CBespace = $Window->AddCombobox( 
    -name   => "CbEspace",
    -left   => 190, 
    -top    => 100,
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



#=====================================================================================================
#							-----------------------  SI C'EST POUR UN HF ----------------------------
#=====================================================================================================

my $TRAIT_HF = $Window->AddLabel(
    -text   => "- - - - SI C'EST POUR UN HF - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - ",
    -left   => 5,
    -top    => 130,
);


my $ZIP_NAME_LABEL = $Window->AddLabel(
    -text   => "Nom du fichier ZIP:",
    -left   => 10,
    -top    => 155,
);


my $zip_name = $Window->AddTextfield(
       -text    => "",
       -name    => "zip_name",
       -left    => 110,
       -top     => 155,
       -multiline => 1,
       -width   => 100,
       -height  => 20,
      );
	  
my $ZIP_EXT_LABEL = $Window->AddLabel(
    -text   => ".zip",
    -left   => 212,
    -top    => 155,
);


#=====================================================================================================
#							-----------------------  si c'est pour Patcher La VM -------------------
#=====================================================================================================
my $TRAIT_VM = $Window->AddLabel(
    -text   => "- - - - SI C'EST POUR PATCHER UNE VM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
    -left   => 5,
    -top    => 190,
);


my $patch_vm = $Window->AddCheckbox(
    -name   => "patch_vm", 
	-left   => 20, 
	-top => 215, 
	-height => 25, 
	-width  =>300, 
	-text   => "Redemarrer MEGA sur la VM et Patcher la DLL buildé",
);

my $send_mail_patch = $Window->AddCheckbox(
    -name   => "send_mail_patch", 
	-left   => 20, 
	-top => 240, 
	-height => 25, 
	-width  =>300, 
	-text   => "Envoyer un Mail pour informer cette opération",
);



#=====================================================================================================
#							QA quick tests
#=====================================================================================================
my $TRAIT_QA = $Window->AddLabel(
    -text   => "- - - - SI C'EST POUR la QA TEST  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
    -left   => 5,
    -top    => 280,
);


my $qa_test = $Window->AddCheckbox(
    -name   => "qa_test", 
	-left   => 20, 
	-top => 305, 
	-height => 25, 
	-width  =>320, 
	-text   => "Envoyer la DLL build à la QA",
);






#=====================================================================================================
#							fin de window et GO button
#=====================================================================================================
my $TRAIT_QA = $Window->AddLabel(
    -text   => "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
    -left   => 5,
    -top    => 340,
);


		#							BUTTONS "OK" AND "Cancel"

my $OK = $Window->AddButton( 
	-name => "OK",
	-top => 365,  
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
    -top => 365,  
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











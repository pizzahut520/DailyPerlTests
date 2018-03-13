# ---------------------------------------------------------------------------------------------------
# HGT / XYU 6/10/2011
# Ajout pour tracer les scripts appelés
system("w:\\tools\\scripttrace.pl $0");
# ---------------------------------------------------------------------------------------------------

######################
# Interface
######################

use File::DosGlob 'glob';
use Win32::FileOp;
use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use File::Compare;

#-----------------------------------------------------------------------------------------------------
# Minimize the Perl's DOS window
($DOShwnd, $DOShinstance) =Win32::GUI::GetPerlWindow();
Win32::GUI::CloseWindow($DOShwnd);

#-----------------------------------------------------------------------------------------------------


# NOTE: $C should be Win32::GUI::Cursor...
$I = new Win32::GUI::Icon("exploitr.ico");
$WC = new Win32::GUI::Class
	(
    -name => "Mega win32_gui", 
    -icon => $I,
	);

# Assume we have the main window size in ($w, $h) as before
$desk = Win32::GUI::GetDesktopWindow();
$dh = Win32::GUI::Height($desk);

if ($dh > 768 ) 
{
    $wh = $dh-80;
    $th = $dh-280;
} 
else 
{
    $wh = 730;
    $th = 540;
}

$Window = new Win32::GUI::DialogBox
(
    -name   => "Window",
    -left   => 5, 
    -class => $WC,
    -top    => 3,
    -width  => 960, 
    -height => $wh,
    -sysmenu => 1,
    -minimizebox => 1,
    -maximizebox => 0,
    -text   => "Comparaison de dossiers",
);

#$sw = $Window->ScaleWidth();
#$sh = $Window->ScaleHeight();


#-----------------------------------------------------------------------------------------------------
#  Affichage de la Combo Version
#-----------------------------------------------------------------------------------------------------

################################################################################
$Window->AddLabel
(
    -name   => "TXdirlbl1", -text   => "Répertoire 1: ", -left   => 70, -top    => 45,
);

my $txt_sdk_local_1 = $Window->AddTextfield
(
  -name   => "txt_sdk_local_1", -text   => "", -left   => 150, -top    => 40, -height => 22, -width  => 160,
);
$txt_sdk_local_1->ReadOnly(1);

my $btn_search_sdk_1 = $Window->AddButton
( 
	-name => "btn_search_sdk_1",  -top => 40, -left => 320, -height => 21, -width => 25, -cancel => 1, -text => "...", -tabstop => 1,
);
#################################################################################
$Window->AddLabel
(
    -name   => "TXdirlbl2", -text   => "Répertoire 2: ", -left   => 70, -top    => 65,
);

my $txt_sdk_local_2 = $Window->AddTextfield
(
  -name   => "txt_sdk_local_2", -text   => "", -left   => 150, -top    => 60, -height => 22, -width  => 160,
);
$txt_sdk_local_2->ReadOnly(1);

my $btn_search_sdk_2 = $Window->AddButton
( 
	-name => "btn_search_sdk_2",  -top => 60, -left => 320, -height => 21, -width => 25, -cancel => 1, -text => "...", -tabstop => 1,
);
#################################################################################
my $btn_Compare = $Window->AddButton
( 
	-name => "btn_Compare", -top => 25,  -left => 500, -height => 22,     -width => 80, -default => 1, -ok => 1,   -text => "Comparer",     -tabstop => 1,
);
$btn_Compare-> Enable(0);

my $btn_cancel = $Window->AddButton
( 
	-name => "btn_cancel", -top => 53,  -left => 500, -height => 22,  -width => 80, -cancel => 1,  -text => "Fermer",  -tabstop => 1,
);

my $Cancel = $Window->AddButton
( 
-name => "Effacer", -top => 81,  -left => 500, -height => 22,  -width => 80, -cancel => 1,  -text => "Effacer Rapport",  -tabstop => 1,
);
	
#-----------------------------------------------------------------------------------------------------
#  Ecriture fenetre
#-----------------------------------------------------------------------------------------------------

sub StreamWrite
{
    my $arg = shift;  
    $TxtOut->AddString("$arg");
    $Window->Update;
}


#-----------------------------------------------------------------------------------------------------
#  Affichage de l'analyse
#-----------------------------------------------------------------------------------------------------

$TxtOut = $Window->AddListbox
(
    -name   => "TxtOut",
    -hscroll => 1,
    -vscroll => 1,
    -menu   => 0,
    -menu   => 0,
    -left   => 10,
    -height => $th,
    -top    => 170,
    -width  => 935,    
);

my $statusbar = $Window->AddStatusBar
( 
	-name => "statusbar", -text => " Comparaison de Dossiers "
);

#-----------------------------------------------------------------------------------------------------
#  InitDialog
#-----------------------------------------------------------------------------------------------------

$Window->Show;
Win32::GUI::Dialog;


#-----------------------------------------------------------------------------------------------------
#  Gestion des traitements
#-----------------------------------------------------------------------------------------------------


sub btn_search_sdk_1_Click
{
	$DirSdkLocal = BrowseForFolder("Si le répertoire souhaité n'existe pas, le créer dans l'explorateur Windows.","",BIF_RETURNONLYFSDIRS|BIF_DONTGOBELOWDOMAIN);
	if($DirSdkLocal ne "" )
	{
		$txt_sdk_local_1->Text($DirSdkLocal);
		$glob_SpathDir_1 = $txt_sdk_local_1->Text;
		Check_Content();
	}
}


sub btn_search_sdk_2_Click
{
	$DirSdkLocal = BrowseForFolder("Si le répertoire souhaité n'existe pas, le créer dans l'explorateur Windows.","",BIF_RETURNONLYFSDIRS|BIF_DONTGOBELOWDOMAIN);
	if($DirSdkLocal ne "" )
	{
		$txt_sdk_local_2->Text($DirSdkLocal);
		$glob_SpathDir_2 = $txt_sdk_local_2->Text;
		Check_Content();
		$Status = $Window->AddStatusBar( -name => "Status",-text => "  Comparaison de Dossiers");
	}
}


sub Window_Terminate
{
    return -1;
}


sub btn_cancel_Click 
{
    return -1;
}


sub Effacer_Click 
{
    if($TxtOut->Count > 0) 
	{
        $TxtOut->Clear;
        $TxtOut->Text("");
    }
}

sub Check_Content 
{
	if (($txt_sdk_local_1->Text eq "") or ($txt_sdk_local_2->Text eq ""))
	{
		$btn_Compare-> Enable(0);
		$Status = $Window->AddStatusBar( -name => "Status",-text => "  Vous devez choisir deux dossiers à comparer");
	}
	else
	{
		$btn_Compare-> Enable(1);
	}
}

#-----------------------------------------------------------------------------------------------------
# Listes de resultats
#-----------------------------------------------------------------------------------------------------


my @DiffFile;
my @OnlyRepSrc;
my @OnlyRepDest;
	
#-----------------------------------------------------------------------------------------------------


sub btn_Compare_Click 
{

	$bEntete = 0;
	$ReportFile = "$ENV{'TEMP'}\\Comparaison_Dossiers.log";
	open(REPORT, ">$ReportFile") or die "Création du fichier de log impossible";

	$btn_Compare->Enable(0);
	StreamWrite("**************** Traitement en cours ***********************");
	StreamWrite(" ");
	StreamWrite(" ");
	
	Traitement($glob_SpathDir_1,$glob_SpathDir_2);

	$Status = $Window->AddStatusBar( -name => "Status",-text => " En cours de traitement ...");
	
	
	#############################################
	# Afficher le résultat									
	#############################################

##################################################################################
# Différences
		
	print REPORT "\n\nFichiers différents :\n\n";
	StreamWrite(" ");
	StreamWrite("Fichiers différents :");
	StreamWrite(" ");
	
	foreach $DFile (@DiffFile)
	{
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		#     Ecriture dans un fichier log dans "c:\temp"
		
		print REPORT "$DFile\n";
		
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		# Ecriture dans la Frame du programme
		
		StreamWrite("$DFile");
	
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
	}
##################################################################################
# Only on rep1	

	print REPORT "\n\nFichiers seulement dans \"$glob_SpathDir_1\" :\n\n";
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite("Fichiers seulement dans \"$glob_SpathDir_1\" :");
	StreamWrite(" ");

	foreach $OnlyFileSrc (@OnlyRepSrc)
	{
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		#     Ecriture dans un fichier log dans "c:\temp"
		
		print REPORT "$OnlyFileSrc\n";
		
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		# Ecriture dans la Frame du programme
		
		StreamWrite("$OnlyFileSrc");

		#-----------------------------------------------------------------------------------------------------------------------------------------------------
	}
##################################################################################
# Only on rep2	

	print REPORT "\n\nFichiers seulement dans \"$glob_SpathDir_2\" :\n\n";
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite("Fichiers seulement dans \"$glob_SpathDir_2\" :");
	StreamWrite(" ");
	
	foreach $OnlyFileDest (@OnlyRepDest)
	{
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		#     Ecriture dans un fichier log dans "c:\temp"
		
		print REPORT "$OnlyFileDest\n";
		
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		# Ecriture dans la Frame du programme
		
		StreamWrite("$OnlyFileDest");
		
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
	}	
##################################################################################
# Fin Traitement

	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite("**************** Fin du Traitement *************************");
	StreamWrite(" Les resultats sont dans le fichier $ReportFile");
	StreamWrite(" ");
	StreamWrite(" ");
	StreamWrite(" ");
    close(REPORT);

	$btn_Compare->Enable(1);
	$Status = $Window->AddStatusBar( -name => "Status",-text => "  Comparaison de Dossiers");
	
	#-----------------------------------------------------------------------------------------------------
	# Minimize the Perl's DOS window
	
	($DOShwnd, $DOShinstance) =Win32::GUI::GetPerlWindow();
	Win32::GUI::CloseWindow($DOShwnd);
	#Win32::GUI::Hide($DOShwnd);
	#-----------------------------------------------------------------------------------------------------
	
}





#-----------------------------------------------------------------------------------------------------
#  Comparaison des deux dossiers
#-----------------------------------------------------------------------------------------------------


sub Traitement
{
	if ($bEntete == 0)
	{
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		#     Ecriture dans un fichier log dans "c:\temp"
						

		print REPORT "\n## Comparaison de dossiers :\n";
		print REPORT "## Dossier source : $glob_SpathDir_1\n## Dossier destination : $glob_SpathDir_2  \n\n\n ";
				
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		# Ecriture dans la Frame du programme
						
						
		StreamWrite(" ");
		StreamWrite("## Comparaison de dossiers :");
		StreamWrite(" ");
		StreamWrite("## Dossier Source : $glob_SpathDir_1");
		StreamWrite("## Dossier Destination : $glob_SpathDir_2");
		StreamWrite(" ");
		StreamWrite(" ");
		#-----------------------------------------------------------------------------------------------------------------------------------------------------
		
		$bEntete = 1;
	}
	
#---------------------------------------------------------------------------------------------------------------------	
	
	my $SpathDir_1 = $_[0];
	my $SpathDir_2 = $_[1];
	my $QSpathDir_1 = quotemeta($SpathDir_1);
	my $QSpathDir_2 = quotemeta($SpathDir_2);
	my $file_2;
	my $srcFile;
	my $tgFile;
	
	my @lstFiles_2; 
	my @lstFiles_1;


	@lstFiles_2 = glob globFileName($SpathDir_2."\\*");
	@lstFiles_1 = glob globFileName($SpathDir_1."\\*");

#---------------------------------------------------------------------------------------------------------------------

	
	foreach $file_2 (@lstFiles_2)
	{
		$srcFile = $file_2;
		$srcFile =~ s/$QSpathDir_2/$SpathDir_1/i;
			
		$RepFile_2 = $file_2;
		$RepFile_1 = $srcFile;
		
		$fileNameDest = substr($RepFile_2,length($glob_SpathDir_2)+1);  # On récupère le nom des répertoires intermédiaires et du fichier traité
		$fileNameSrc = substr($RepFile_1,length($glob_SpathDir_1)+1);	# On récupère le nom des répertoires intermédiaires et du fichier traité
		
		if(-e $RepFile_1)
		{
			if(! -d $RepFile_1)
			{
				# si le fichier existe et n'est pas un repertoire 
				($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$msize1,$atime,$mtime1,$ctime,$blksize,$blocks) = stat($RepFile_2); #2
				($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$msize2,$atime,$mtime2,$ctime,$blksize,$blocks) = stat($RepFile_1);#1
				
				# On compare la taille
				if(($msize1) != ($msize2))
				{
					push(@DiffFile,$fileNameDest);
				}
				else  # Taille égale
				{
						# Contenu des fichiers différents
						if (compare($RepFile_1,$RepFile_2) == 1) 
						{  
							push(@DiffFile,$fileNameDest);
						}	
					
				}
			}
			else
			{
				Traitement($RepFile_1,$RepFile_2);
			}
		}
		else # Right-Only le fichier n'existe pas dans le répertoire source
		{
			push(@OnlyRepDest,$fileNameDest);
		}
	}	
	
	foreach $file_1 (@lstFiles_1)
	{
		$tgFile = $file_1;
		$tgFile =~ s/$QSpathDir_1/$SpathDir_2/i;
			
		# Obtenir le nom du fichier
		$fileNameDest = substr($tgFile,length($glob_SpathDir_1)+1);
		
		if(! -e $tgFile)
		{
			push(@OnlyRepSrc,$fileNameDest);
		}
	}
	
}


#------------------------------------------------------------------------------------------------------
#  Récupération des noms des fichiers dans un dossier
#-----------------------------------------------------------------------------------------------------

sub globFileName()
{
  $_ = $_[0];

  while(s/ /?/) {}

  return $_;
}
	

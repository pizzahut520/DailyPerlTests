use Win32::GUI();






	my $icon_comment = new Win32::GUI::Icon("exploit.ico");
	my $WindowClass = new Win32::GUI::Class(
		-name => "Mega win32_gui", 
		-icon => $icon_comment,
	);

	my $Window_comment = new Win32::GUI::DialogBox(
		-name   => "Window_comment",
		-left   => 100, 
		-class  => $WindowClass,
		-top    => 100,
		-width  => 400, 
		-height => 180,
		-text   => "Add a Comment",
		-resizable => 0,
		-sysmenu => 1,
		-minimizebox => 1,
		-maximizebox => 0,
	);
	
	# $Window_comment->AddTextfield(
        # -name   => "Comment",
        # -left   => 75,
        # -top    => 150,
        # -width  => 100,
        # -height => 20,
        
    # );
	$Window_comment->Show;
	Win32::GUI::Dialog;
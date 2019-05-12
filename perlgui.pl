   	
	
	# package for GUI 
	use Win32::GUI();
	use  File::Path;
	use Thread; 

	#########################
	require 'WebCrawlUp.pl';
	#########################

	#################################################
    #$text = defined($ARGV[0]) ? $ARGV[0] : "Crawler";
    #################################################

    $main = Win32::GUI::Window->new(
                -name => 'Main',
                -text => 'Web Crawler',
        );

    $font = Win32::GUI::Font->new(
                -name => "Comic Sans MS", 
                -size => 24,
        );
   
    $tf1 = $main->AddTextfield(
                -name   => "textFieldSeed",
                -left   => 40,
                -top    => 30,
                -width  => 300,
                -height => 20,
                -prompt => "Seed: ",

    ); 

    $tf2 = $main->AddTextfield(
                -name   => "textAreaLog",
                -left   => 40,
                -top    => 60,
                -width  => 300,
                -height => 300,
		        -multiline => 1,
                -prompt => "Log:",

    ); 

    $btnCrawl = $main->AddButton(
                -name => "buttonCrawl",
                -text => "Crawl Now",
                -pos  => [ 40, 370 ],
    );

	$btnStop = $main->AddButton(
                -name => "buttonStop",
                -text => "Stop",
                -pos  => [ 150, 370 ],
    );

    $ncw = $main->Width() -  $main->ScaleWidth();
    $nch = $main->Height() - $main->ScaleHeight();
    

    $desk = Win32::GUI::GetDesktopWindow();
    $dw = Win32::GUI::Width($desk);
    $dh = Win32::GUI::Height($desk);
    $x = ($dw - $w) / 2;
    $y = ($dh - $h) / 2;

    $main->Change(-minsize =>[390,480] );
   

    $main->Resize($w, $h);
    $main->Move($x, $y);
    $main->Show();

    Win32::GUI::Dialog();

    sub Main_Terminate {
        -1;
    }

    sub Main_Resize {
        my $mw = $main->ScaleWidth();
        my $mh = $main->ScaleHeight();
    }
	
	sub showLog
	{
		$tf2->Append(@_[0]);
				$tf2->Append( "\r\n" );
	}

	sub buttonCrawl_Click {
		   		rmtree(['url'], 1, 1) ;
		       rmtree(['OutputDir'], 1, 1) ;
		       rmtree(['html'], 1, 1) ;

				$seedUrl = $tf1->Text;
				&CrawlMain ($seedUrl);
				return 0;
    }

    sub buttonStop_Click {
		      &stopNow($main);
    			return 0;
    }




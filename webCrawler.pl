
# Web Crawler 
# \perl\eg\IRProject

# Author : Afroza Ahmed , UUID: 00242452
# Project-7130
# Due date 11/25/08 

#################################################################################################################################################

use Thread qw(yield async);

$SIG{KILL} = sub {
	threads->exit(); 
	};


#Subroutine Preprocessor: This subroutine preprpcesses a string content passed as first parameter and saves as 
#                         filename passed as second parameter

sub Preprocessor
{
	my $FileContent = $_[0];   # First parameter passed to this subroutine, the string content to be preprocessed
	my $filename = $_[1];      # Second parameter passed to this subroutine, the filename
	$filename=$gOutputDir.$filename;
	print $filename;
	print LOGFILE "Content of the File: ".$FileContent."\n";
	$FileContent = lc $FileContent;   # make lowercase
	print LOGFILE "Converted to lc and spaced: ".$FileContent."\n";
	$FileContent = Tokenizer($FileContent);           # Call subroutine Tokenizer to tokenize
	print LOGFILE "After Tokenization: ".$FileContent."\n";
	open (WRITEFILE, ">$filename") || die " 1Could not open file $name. Exit.";
	print WRITEFILE $FileContent;		# Save preprocessed contents
	close WRITEFILE;
}

#Subroutine Tokenizer: This subroutine Tokenizes and returns the tokenized contents 
#                      

sub Tokenizer
{	
	my $gLine=$_[0];		# First parameter passed to this subroutine, the string content to be tokenized
	$gLine =~ s/[^a-z ]//g;
	my $docContent="";       
	@gWords=split(/\s/, $gLine);	# Splits based on space and makes an array of words

	foreach $word (@gWords)			# Iterate over each splitted words(token)
	{	
		if($word=~/[-=:;^\|\[\]\#\"\&\$\*\?\+\(\),\/\'\.0-9]/)
		{							 # If the token is anyone of these symbols, then skip as we need only 
			next;					 # string of alphabets
		}
		$docContent=$docContent.$word.' ';
	}
	return $docContent;
}



#Subroutine Crawler: This subroutine crawls the seed

sub Crawler
{
	#crawler log file reports all links visited  
	open (LOGFILE, '>crawler_log.txt') || die " 3Could not open file $file. Exit.";
	#crawler error log file reports all errors (currently not being used) 
	open (FAILURELOGFILE, '>crawler_failure_log.txt') || die " 4Could not open file $file. Exit.";
	#prints all url in every step
	open (ALLURLFILE, '>URLsFromAllPages.txt') || die " 5Could not open file $file. Exit.";
	#prints all url in the queue in every step
	open (QUEUESTATUS, '>QueueStatus.txt') || die " 6Could not open file $file. Exit.";
	#prints all filenames that is counted as a document
	open(FILENAMES, ">filenames.txt")|| die " 7Could not open file $ARGV[0]. Exit.";

   

	# NOTE: All these files above  are for ease of tracking/debugging

	# Seed url to start with
	$gSeedURL  = @_[0];
			# mkdir($gSeedURL, 0755) ;
	
	#@queue = qw($gSeedURL);  
	unshift(@queue, $gSeedURL);

	#hash for tracking pages visited
	$gVisitedPages{$gSeedURL}++;

	#&showLog($gSeedURL." hash table entry ".$gVisitedPages{$gSeedURL});

	$countDocumentsStored=0;   # counter for tracking termination document count

	$url = $gSeedURL;
	print LOGFILE "Processing: $url";
	&showLog("Processing: $url");
	#print "Processing: $url";

   
	while($url)					# while a valid url is popped out of the queue
	{
		 if($url=~m/\.pdf/)

         {   
		  print "PDF found $url";
		  &showLog("PDF found $url");
	 
          system "lwp-download  $url pdf";
		  &showLog("Executing ...   $url pdf");
         }

		 if ($url=~m/\.(jpg|jpeg|gif|png)/  )
			 {
				 system "lwp-download  $url image"
				 &showLog("Executing ...   $url image");
			 }


     	&ProcessURLs;			# Call subroutine ProcessURLs (Processes every url, saves text contents and urls in separate files)	
		if(!is_success($status)) # if the page is not successfully downloaded as local copy, go for next from the queue
		{
			print "Not Success......";
			&showLog( "Not Success......");
			print LOGFILE "  Not Success......";
			$url = pop @queue;	# pop from the queue to get the url
			print "\nProcessing: $url";
			&showLog("Processing: $url");
			print LOGFILE "\nProcessing: $url";
			next;
		}
		else
		{
			&EnqueueURLs;		# call subroutine EnqueueURLs which enques unique and new urls into the queue

			print QUEUESTATUS "\n\n------------------------------------------------------------------------------\n";
			print QUEUESTATUS "$url\n\n\n";
			print QUEUESTATUS " @queue";

			$url = pop @queue;	# pop from the queue to get the url
			print "\nProcessing: $url";
			&showLog("Processing: $url");
			print LOGFILE "\nProcessing: $url";
		}
			$count++;


	 }
	
	close ALLURLFILE;
	close QUEUESTATUS;
	close LOGFILE;
	close FAILURELOGFILE;
	close FILENAMES;
}


#Subroutine EnqueueURLs: This subroutine reads the URL file for each lin and enques the unique and new links 
#						 into the queue.

sub EnqueueURLs
{
	 open (INPUTFILE, 'URLsFromThisPage.txt') || die " 8Could not open file $file. Exit.";
				# temporary file that has the list of urls for the current page
	 while(<INPUTFILE>)
	 {
		# print $_;
		chomp($_);
		 if (exists $gVisitedPages{$_}) 
		 {					# if the urls is already visited, exists in the hash then do nothing
			break;
		 }
		 else			   # if not, then add this in the queue as well as in the hash
		 {
			$gVisitedPages{$_}++;
			unshift(@queue, $_);
		 }
	 }
	 close INPUTFILE;
	 unlink("URLsFromThisPage.txt");   # remove the temporary file
}

#Subroutine ProcessURLs: Processes every url, saves text contents and urls in separate files

sub ProcessURLs
{
	#use strict;
	#use warnings;
	use LWP::Simple;		      # use LWP perl module
	$url =~ m/http:\/\/(.*)/;     # extract only the url part without http://
	$urlWithoutHTTP=$1;
	$urlWithoutHTTP =~ s/\//_/g;  # replace each / by _ (as / is not taken as a part of file name)
	#mkdir($urlWithoutHTTP,0755);
	$file = "C:\\Perl\\eg\\IRProject\\html\\".$urlWithoutHTTP.".html";

								  # file name for local copy of the page 	
	$status = getstore($url, $file);  # get the webpage and save as a local copy

	if(!is_success($status))	  # if it doesnt successfuly get the page
	{
		return;
	}
#	die "Error $status on $url" unless is_success($status);
              
	&GetUrls;					 # call subroutine GetUrls, extracts urls from the page
	&GetContent;			     # call subroutine GetContent, extracts the contents of the file and save as a text file 

	if($countDocumentsStored==1000)	# if total 1000 documents accumulated, finished
		{
			print "\n\nFinished!!!";
			&showLog("Finished!!!");
			return 0;
		}
}

#Subroutine GetContent: This subroutine calls ReadHTMLFile subroutine to read the locally saved HTML file and 
#						makes it a single line eliminating all newline characters, as a part of preprocessing.
#                       Also calls RemoveHTMLTag subroutine to remove all HTML tags and save as a text file.

sub GetContent
{
	&ReadHTMLFile;		# call subroutine ReadHTMLFile
	&RemoveHTMLTag;		# call subroutine RemoveHTMLTag 
}

#Subroutine GetUrls: This subroutine reads the HTML file, finds the URLs in it (if any) and finally makes 
#                    a list of candidate URLs for next phase enqueing.

sub GetUrls
{
	# open locally saved HTML file
	open (INPUTFILE, $file) || die " 8Could not open file $file. Exit.";
	# temporary file for content
	open(OUTPUTFILE, ">outputTemp.txt")|| die " 9Could not open file $ARGV[0]. Exit.";

	@Content=<INPUTFILE>;	# grab HTML contents
    close INPUTFILE;
	
	$ContentString="";

	for($i=0;$i<$#Content;$i++)		# get the content in a single scalar
	{
	  $ContentString= $ContentString.$Content[$i] ; 
	}
			
	$ContentString =~ s/href/\nhref/g;		# replace every href pattern with a newline before it for unique detection in next phase
	@Content=$ContentString;
	
	print OUTPUTFILE @Content;   	# save the content in a temporary file
	close OUTPUTFILE;
	
	open(INPUTFILE, "outputTemp.txt")|| die " 10Could not open file $ARGV[0]. Exit.";
	@NewContent=<INPUTFILE>;		# read the content from temporary file
	close INPUTFILE;
	unlink("outputTemp.txt");		# remove temporary file

	# open file for candidate URLs
	open(OUTPUTFILE, ">URLsFromThisPage.txt")|| die " 11Could not open file $ARGV[0]. Exit.";
	print ALLURLFILE "\n\n------------------------------------------------------------------------------\n";
	print ALLURLFILE "$url\n\n\n";

	for($i=0;$i<$#NewContent;$i++)    # for each line of the content
	{ 
	  if ($NewContent[$i] =~ m/href="(.*?)"/i)   # if there is a pattern href then thats the starting of an URL
	  {
	  	$ChildURL = $1;							 # gets the new URL as child URL
		
		if(!($ChildURL =~ m/\#/g))				 # if the new URL has # in it then ignore it and consider only those without #
        {
			if($ChildURL =~ m/^\//)				 # if the new URL is a relative URL, then add the parent URL before it
			{
				$ChildURL=$gSeedURL.$ChildURL;
			}

				if(!(($ChildURL =~ m/^mailto/)||($ChildURL =~ m/^http:\/\/mailto/)))  # ignore any URL that has mailto or http://mailto in it
				{	
				  $ChildURL =~ s/\/$//;         # remove any / at the end
				  if(($ChildURL =~ m/\.ico$/)||($ChildURL =~ m/\.pl$/)||($ChildURL =~ m/\.css$/)||($ChildURL =~ m/\.dwf$/) ||($ChildURL =~ m/\.php$/) ||($ChildURL =~ m/\.tif$/)||($ChildURL =~ m/\.asp$/)||($ChildURL =~ m/\.zip$/) ||($ChildURL =~ m/\.xls$/)||($ChildURL =~ m/\.ppt$/)||($ChildURL =~ m/\.doc$/)||($ChildURL =~ m/\.com$/))
				  {								# this crawler cant deal with these file formats
				  }
				  else
				  {								# print the new URL
					  print OUTPUTFILE "$ChildURL\n";
					  print ALLURLFILE "$ChildURL\n";
				  }
				}
			
		}
	  }
 	}
	close INPUTFILE;
	close OUTPUTFILE;
}


#Subroutine ReadHTMLFile: This subroutine reads the HTML file and makes it a single line eliminating 
#			              all newline characters, as a part of preprocessing.

sub ReadHTMLFile
{
	open (INPUTFILE, $file) || die " 12Could not open file $file. Exit.";
	$gLine="";
	$gTotalFileInALine="";
	while ($gLine=<INPUTFILE>)								# Reads lines from file
	{
		chomp($gLine);										# Eliminate newlines
		$gTotalFileInALine=$gTotalFileInALine.' '.$gLine;	# Add up to a single line
	}
	close INPUTFILE;
	unlink($file);
}

#Subroutine ReadHTMLFile: This subroutine removes all HTML tags from the single line HTML code. 

sub RemoveHTMLTag
{
	#open(OUTPUTFILE2, ">C:\\Perl\\eg\\IRProject\\html\\".$countDocumentsStored.$urlWithoutHTTP)|| die " 23Could not open file $ARGV[0]. Exit.";
    # print OUTPUTFILE2 $gTotalFileInALine;
	#close OUTPUTFILE2;

	$gTotalFileInALine =~ s/<!--.*?-->//g;							    # Strip comments (if any)  

	while (   $gTotalFileInALine =~ s/<(?!--)[^'">]*"[^"]*"/</g 
		   or $gTotalFileInALine =~ s/<(?!--)[^'">]*'[^']*'/</g) {};	# Strip HTML tags with double quotes in them
																		# strip from after the start of the tag  up to the end	
																		# of the first quoted string, repeatedly, ending in either
																		# `<>' or `<no quotes here>'

	$gTotalFileInALine =~ s/<(?!--)[^">]*>//g;						
												    # Strip HTML tags without quotes in them.
	$gTotalFileInALine =~ s/&nbsp;/ /g;;			# remove &nbsp;
	$gTotalFileInALine =~ s/&amp;/ /g;;				# remove &amp;
	$gTotalFileInALine =~ s/\s+/ /g;;				# Truncating multiple spaces into one, if any.
	$gTotalFileInALine =~ s/^\s+//g;				# Removing initial space, if any.
	$gTotalFileInALine=~s/\s+$//g;					# Truncating end space, if any
	@totalWords=split('\s', $gTotalFileInALine);	# split by space
	if($#totalWords > 50)                           # if this document has more than 8 words in it, then consider it
	{
		open(OUTPUTFILE, ">C:\\Perl\\eg\\IRProject\\url\\".$countDocumentsStored."_".$urlWithoutHTTP.".txt")|| die " 13Could not open file $ARGV[0]. Exit.";
	   
		print OUTPUTFILE $gTotalFileInALine;

		close OUTPUTFILE;
		#close OUTPUTFILE2;
		print FILENAMES $countDocumentsStored."_".$urlWithoutHTTP.".txt\n";

		$countDocumentsStored++;					# increment document count
		print " ".$countDocumentsStored;
		print LOGFILE " ".$countDocumentsStored;
	}
	
}


#---------------------------------Main Program----------------------------------------------------

# Input: Directory Containing the HTML files (or text files)
# Main calls two function: a) Crawler - crawls the given domain and gets 1000 HTML pages as text files, download pdf files, image files in separate folders 
#  b) Preprocessor - preprpcesses a string content

sub CrawlMain{

$seedUrl= @_[0];

   mkdir("html",0755);
	mkdir("url", 0755) ;

		if (-d "pdf") {
		rmtree(['pdf'], 1, 1); 
			#|| die "Cannot rmdir url";
		}
		else {
		mkdir("pdf", 0755) ;
			#|| die "Cannot mkdir newdir: $!";
		}

$runner  = async{
new Thread  \&Crawler($seedUrl) ;
yield;
};

$directory = "url";						            # Read directory path e.g: \perl\eg\IRProject
chomp($directory);                               # Get rid of tailing newline 


opendir(DIRHANDLE, $directory) || die "Cannot opendir $directory";
open (LOGFILE, '>tokenization_log.txt') || die " Could not open Logfile. Exit.";

$gOutputDir="OutputDir\\"; 
mkdir("OutputDir", 0755) || die "Cannot mkdir newdir: $!";
											# Create new output directory;
foreach $name (sort readdir(DIRHANDLE))     # For each file in that directory
{
	if(($name eq ".") || ($name eq ".."))   # Get rid of current directory and parent directory
	{
		next;
	}
    print LOGFILE "$name\n"; 
	chomp($name);
	open (FILE, $directory."\\".$name) || die " 15Could not open file $name in the directory. Exit.";

	my @FileContent = <FILE>;              # Open file and get the content in array 
	&Preprocessor(@FileContent, $name);    # Call Preprocessor subroutine to preprocess

	print "File Opened: $name\n";
	close FILE;
} 

close LOGFILE;
closedir(DIRHANDLE);

}


#to stop crawling 
sub stopNow
{
	$runner->kill('KILL')->detach();
	$main->MessageBox("Stopped !!", "Message",0x001000|0x000030);
	
}	 

return 1;

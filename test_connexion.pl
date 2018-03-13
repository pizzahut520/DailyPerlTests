#!/usr/bin/perl 

#--------------------------
#rtc_test_session
#--------------------------

use Mega::RTC::Sessions;

use strict;



print "\nstart";

my $res=1;

print"\n rtc_start_session"; 

my $NewCcmAddr = rtc_start_session("modeling","cli");
if($NewCcmAddr){
	print "\nOpened\n";
} else {
	print "\nError appeared while opening a new session. Please check Synergy/CM log files or contact build management team.\n";	
   $res=0;
}

if($res)
{
   #$ENV{'RTC_ADDR'}="SRVHLE";

   print"\n rtc_test_session"; 
   my $res = rtc_test_session;   
}

if($res)
{
   print"\nrtc_stop_session"; 
   $res = rtc_stop_session;    
}

if($res ne "1")
{
   print "\nbad";
}
else
{
   print "\nok";
}  
   

print "\nfin";
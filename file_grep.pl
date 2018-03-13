
use File::Grep qw( fgrep fmap fdo );


 if ( fgrep  "C:\\teini.log" "#ko" ) { print "ko";}
 if ( fgrep  "C:\\teini.log" "#ok" ) { print "ok";}
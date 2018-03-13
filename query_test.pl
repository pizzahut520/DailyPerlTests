
use XML::Simple;
use Data::Dumper;



my $file = "c:\\temp\\projet.xml";
# system("curl.exe -k -g -b %COOKIES% https://vp-pgr-rtc.fr.mega.com:9443/ccm/rpt/repository/workitem?fields=workitem/workItem[summary='$Project']/(id) > $file");

$xml = new XML::Simple;


my $ref = $xml->XMLin($file);

print $ref->{workItem}->{id};
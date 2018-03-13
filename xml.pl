


use XML::Simple;
use Data::Dumper;


$xml = new XML::Simple;
$report_file = "c:\\temp\\projet__Look_and_Feel_wi_creation_log.xml";
$ref = $xml->XMLin($report_file);

print $ref->{'dc:identifier'};


#!/usr/bin/perl
# binmode STDOUT, ":utf8";
# imports encode_json, decode_json, to_json and from_json.
use JSON; 

my $json;
{
	local $/;
	open my $fh, "<","C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\showStatus.json";
	$json = <$fh>;
	close $fh;
}


my $data = decode_json($json);

print "Boss hobbies: ".
	$data->{'boss'}->{'Hobbies'}->[1]. "\n";








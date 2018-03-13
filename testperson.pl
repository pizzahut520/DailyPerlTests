#! /usr/bin/perl
use strict;
use warnings;

use XML::Simple;

my $parser = XML::Simple->new(KeepRoot => 1);

my $doc = $parser->XMLin('C:\\temp\\person.xml');
# use Data::Dumper;
# print Dumper($doc);



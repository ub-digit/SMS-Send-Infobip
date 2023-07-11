#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'SMS::Send::Infobip' ) || print "Bail out!\n";
}

diag( "Testing SMS::Send::Infobip $SMS::Send::Infobip::VERSION, Perl $], $^X" );

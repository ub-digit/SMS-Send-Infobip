#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use SMS::Send;

plan tests => 2;

my @drivers = SMS::Send->installed_drivers;

ok ( scalar (@drivers) >= 1, 'Found at least 1 driver' );
ok ( scalar (grep { $_ eq 'Infobip' } @drivers ) == 1, 'Found "Infobip" driver' );

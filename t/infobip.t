#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use SMS::Send;

plan tests => 6;

my $sender;
eval { $sender = SMS::Send->new('Infobip'); };

like($@, qr/requires _apikey parameter/, 'Croaks if missing required constructor parameter');
ok(!$sender, 'Not instantiated if missing required arguments');

eval {
    $sender = SMS::Send->new('Infobip',
        _apikey => 'apikey',
        '_sender' => '<sender>',
        '_baseurl' => '<identifier>.api.infobip.com',
        '_skip_send' => 1
    );
};

ok(!'', 'No errors thrown when providing required constructor arguments');
ok($sender, 'Instantiated if provided with required arguments');

my $result;
eval {
    $result = $sender->send_sms(text => 'Text message', 'to' => '+41793026727');
};

ok(!$@, 'No errors thrown when sms_send called on sender instance with _skip_send parameter set to true');
ok($result, 'send_sms returns true if called on sender with _skip_send parameter set to true');

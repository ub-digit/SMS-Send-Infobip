package SMS::Send::Infobip;

use 5.006;
use strict;
use warnings;

use parent 'SMS::Send::Driver';

use Carp;
use HTTP::Tiny;
use JSON;

=head1 NAME

SMS::Send::Infobip - SMS::Send driver for Infobip

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    my $sender = SMS::Send->new('Infobip',
        _apikey => 'apikey',
        _sender => 'Sender',
        _baseurl => '<identifier>.api.infobip.com'
    );

    my $sent = $sender->send_sms(
        text => 'Text message',
        to => '41793026727',
    );

=cut

=head1 DESCRIPTION

An SMS::Send driver providing integration with the Infobib SMS API.

=head1 METHODS

=head2 new

    my $sender = SMS::Send->new('Infobip',
        _apikey => 'apikey',
        _sender => 'Sender',
        _baseurl => '<identifier>.api.infobip.com',
        _timeout => 60,
        _to_override => '41793026728',
        _skip_send => 1
    );

=head3 Parameters

=over

=item * C<_apikey> The API key can be retrieved from the Infobip account settings

=item * C<_sender> Name of the sender. See L<https://www.infobip.com/docs/sms/get-started#sender-names> forvalid sender name formats.

=item * C<_baseurl> Personalized base URL in the format: <identifier>.api.infobip.com.

=item * C<_timeout> Optional: Request timeout in seconds, default is 60.

=item * C<_to_override> Optional: An override for the C<to> parameter of C<SMS::Send-E<gt>send_sms()>.

=item * C<_skip_send> Optional: An boolean, if true don't perform the API request to actually send the SMS.

=back

=cut

# TODO: https://www.infobip.com/docs/sms/get-started#sender-names

sub new {
    my ($class, %params) = @_;

    foreach my $param (qw(_apikey _sender _baseurl)) {
        unless (exists $params{$param}) {
            croak $class . "->new requires $param parameter";
        }
    }

    my $self = \%params;
    bless $self, $class;


    return $self;
}

sub send_sms {
    my ($self, %params) = @_;

    my %http_attributes = (
        timeout => 60
    );
    %http_attributes = map { $_ => $self->{"_$_"} // $http_attributes{$_} } keys %http_attributes;

    my $json = JSON->new->utf8;

    my $content = $json->encode(
        {
            messages => [
                {
                    destinations => [
                        {
                            to => $self->{_to_override} // $params{to}
                        }
                    ],
                    from => $self->{_sender},
                    text => $params{text}
                }
            ]
        }
    );

    my $endpoint_url = "https://" . $self->{_baseurl} . "/sms/2/text/advanced";

    return 1 if $self->{_skip_send};

    my $response = HTTP::Tiny->new(%http_attributes)->post(
        $endpoint_url,
        {
            headers => {
                'content-type' => 'application/json',
                'authorization' => "App " . $self->{_apikey}
            },
            content => $content
        }
    );

    return 1 if $response->{success};

    my $error = "Send SMS request failed with status code $response->{status}";

    if ($response->{content}) {
        my $data = $json->decode($response->{content});
        if (
            exists $data->{requestError} &&
            exists $data->{requestError}->{serviceException}
        ) {
            $error .= sprintf(
                ", serviceException: %s",
                $json->encode($data->{requestError}->{serviceException})
            );
        }
    }
    else {
        $error .= ", reason was: $response->{reason}"
    }
    croak $error;
}

=head1 AUTHOR

David Gustafsson, C<< <david.gustafsson at ub.gu.se> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-sms-send-infobip at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=SMS-Send-Infobip>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SMS::Send::Infobip


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=SMS-Send-Infobip>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/SMS-Send-Infobip>

=item * Search CPAN

L<https://metacpan.org/release/SMS-Send-Infobip>

=back

=head1 LICENSE AND COPYRIGHT

This software is Copyright (C) 2023 by David Gustafsson.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)
=cut

1; # End of SMS::Send::Infobip

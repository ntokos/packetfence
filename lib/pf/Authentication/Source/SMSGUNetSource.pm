package pf::Authentication::Source::SMSGUNetSource;

=head1 NAME

pf::Authentication::Source::SMSGUNetSource

=head1 DESCRIPTION

Custom JSON POST SMS Gateway for PacketFence
=cut

use pf::Authentication::constants;
use pf::constants qw($TRUE $FALSE);
use pf::error qw(is_success);
use pf::log;
use JSON; # Required to build the JSON payload
use LWP::UserAgent;
use HTTP::Request;

use Moose;

extends 'pf::Authentication::Source';
with qw(pf::Authentication::CreateLocalAccountRole pf::Authentication::SMSRole);

# Define the type as it will appear in the PacketFence backend
has '+type'                     => (default => 'SMSGUNet');
has '+class'                    => (isa => 'Str', is => 'ro', default => 'external');
has '+dynamic_routing_module'   => (is => 'rw', default => 'Authentication::SMS');

# These 'has' attributes will automatically become configurable fields in the PacketFence GUI
has 'api_url'       => (isa => 'Str', is => 'rw', default => 'https://sms-services.gunet.gr:9999/sendSMS');
has 'service_id'    => (isa => 'Str', is => 'rw' );
has 'message_id'    => (isa => 'Str', is => 'rw', default => 'OTP_SEND');
has 'institution'   => (isa => 'Str', is => 'rw' );
has 'preshared_key' => (isa => 'Str', is => 'rw' );
has 'message'       => (isa => 'Maybe[Str]', is => 'rw', default => '$pin');

=head2 available_rule_classes
=cut

sub available_rule_classes {
    return [ grep { $_ ne $Rules::ADMIN } @Rules::CLASSES ];
}

=head2 available_actions
=cut

sub available_actions {
    my @actions = map( { @$_ } $Actions::ACTIONS{$Rules::AUTH});
    return \@actions;
    
}

=head2 available_attributes
=cut

sub available_attributes {
  my $self = shift;
  my $super_attributes = $self->SUPER::available_attributes;
  return [@$super_attributes];
}

=head2 match_in_subclass
=cut

sub match_in_subclass {
    my ($self, $params, $rule, $own_conditions, $matching_conditions) = @_;
    return ($params->{'username'}, undef);
}

=head2 sendSMS

Send POST request with JSON payload to custom SMS gateway
=cut
sub sendSMS {
    my ($self, $info) = @_;

    my $to = $info->{to};
    
    # PacketFence has already swapped '$pin' for the real PIN here
    my $message_text = $info->{message}; 

    my $logger = pf::log::get_logger;

    # Construct the JSON payload structure
    my $payload = {
        "serviceId"      => $self->service_id,
        "messageId"      => $self->message_id,
        "recipient"      => $to,
        "institution"    => $self->institution,
        "pre-shared key" => $self->preshared_key,
        # Wrap the message in an array reference so it encodes as ["PIN: 1234"]
        "replacements"   => [ $message_text ] 
    };

    my $json_content = encode_json($payload);
    my $url = $self->api_url;

    # Initialize the User Agent
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10); 

    # Build the POST request
    my $request = HTTP::Request->new(POST => $url);
    $request->header('Content-Type' => 'application/json');
    $request->content($json_content);

    # Execute the request
    my $response = $ua->request($request);

    unless($response->is_success) {
        $logger->error("Can't send SMS to '$to': HTTP " . $response->code . " - " . $response->message);
        $logger->error("SMS Gateway Response Body: " . $response->decoded_content);
        return $FALSE;
    }

    $logger->info("SMS sent successfully to '$to' (Network Activation)");
    return $TRUE;
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

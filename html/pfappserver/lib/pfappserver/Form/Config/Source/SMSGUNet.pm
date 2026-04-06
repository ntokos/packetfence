package pfappserver::Form::Config::Source::SMSGUNet;

=head1 NAME

pfappserver::Form::Config::Source::SMSGUNet

=head1 DESCRIPTION

Form definition to create or update a Custom JSON SMS authentication source.

=cut

use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';
with 'pfappserver::Base::Form::Role::SourceLocalAccount';

# Load the backend source to read default values
use pf::Authentication::Source::SMSGUNetSource;

has_field 'api_url' => (
    type        => 'Text',
    label       => 'API URL',
    required    => 1,
    default     => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('api_url')->default,
    tags        => {
        after_element   => \&help,
        help            => 'The HTTP/HTTPS endpoint for your custom SMS Gateway (e.g.,https://sms-services.gunet.gr:9999/sendSMS)',
    },
);

has_field 'service_id' => (
    type        => 'Text',
    label       => 'Service ID',
    required    => 1,
    #    default     => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('service_id')->default,
    tags        => {
        after_element   => \&help,
        help            => 'The Service ID required by the JSON payload',
    },
);

has_field 'message_id' => (
    type        => 'Text',
    label       => 'Message ID',
    required    => 1,
    default     => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('message_id')->default,
    tags        => {
        after_element   => \&help,
        help            => 'The Message ID required by the JSON payload',
    },
);

has_field 'institution' => (
    type        => 'Text',
    label       => 'Institution',
    required    => 1,
    #    default     => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('institution')->default,
    tags        => {
        after_element   => \&help,
        help            => 'Institution string sent in the JSON payload',
    },
);

has_field 'preshared_key' => (
    type        => 'ObfuscatedText',
    label       => 'Pre-shared Key',
    required    => 1,
    default     => '',
    tags        => {
        after_element   => \&help,
        help            => 'The secret key required to authenticate with the SMS API',
    },
);

has_field 'message' => (
    type        => 'TextArea',
    label       => 'Replacements value $pin',
    required    => 1,
    default     => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('message')->default,
    tags        => {
        after_element   => \&help,
        help            => 'Replacements value $pin',
    },
);
has_field 'pin_code_length' => (
    type => 'PosInteger',
    label => 'PIN Code Length',
    default => pf::Authentication::Source::SMSGUNetSource->meta->get_attribute('pin_code_length')->default,
    tags => {
        after_element => \&help,
        help => 'The length of the PIN code to be sent over sms',
    },
);

1;

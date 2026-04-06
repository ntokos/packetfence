package pf::web::custom;

=head1 NAME

pf::web::custom - custom code to override pf::web's behavior

=cut

=head1 DESCRIPTION

pf::web::custom allows you to redefine subs in pf::web.
It will never be overwritten when upgrading PacketFence.

=cut

use strict;
use warnings;
use Date::Parse;
use File::Basename;
use POSIX;
#use JSON::MaybeXS;
use JSON::MaybeXS qw(decode_json); # Make sure to import decode_json
use Template;
use Locale::gettext;
use pf::log;
use Readonly;

use pf::config;
use pf::util;
use pf::ip4log;
use pf::node qw(node_attributes node_view node_modify);
use pf::web;
use LWP::UserAgent; # Needed by the Node.js API call

=head1 WARNING

What we are doing here is a little bit tricky: We are redefining subs in pf::web.

To do so, we are messing with typeglobs installing anonymous subs in the pf::web namespace
replacing earlier implementations.

=cut

#-------------------------------------------------------------------------------------------
# Customization of the captiveportal::dispatch method to intercept a /signup call
# during the login attempt in order to verify the CAPTCHA token with the Node.js server.
#-------------------------------------------------------------------------------------------

require captiveportal;

# Grab the inherited Catalyst dispatch method
my $orig_dispatch = captiveportal->can('dispatch');

if ($orig_dispatch) {
    my $logger = get_logger();
    no warnings 'redefine';
	
    # Our custom dispatch method for interception of portal requests
    *captiveportal::dispatch = sub {
        my ($c, @args) = @_;

        # Intercept portal requests to the signup/registration route
        my $path = $c->request->path || '';
		
        if ($path =~ m{^signup}i && $c->request->method eq 'POST') {
	    $logger->debug("Path matched route 'signup'");
            
            my $token = $c->request->body_parameters->{'captcha_token'};
            my $is_valid = 0;
			
	    $logger->debug("Body parameter captcha_token has value: $token");

            # Verify token against Node.js server
            if ($token) {
                my $ua = LWP::UserAgent->new;
                $ua->timeout(5); # Don't hang the portal if the Node server is down
                
		$logger->debug("Checking token with node.js server");
		
		# Send the secret key to the Node server
		$ua->default_header('X-Custom-API-Key' => 'UseStrongerAuthXKey');
    
		my $response = $ua->get("https://${pf::config::fqdn}:3030/check-token?token=$token");
				
                if ($response->is_success) {
		    $logger->debug("Successfully connected to Node.js server");

                    eval {
                        my $json = decode_json($response->decoded_content);
                        $is_valid = 1 if $json->{valid};
                    };
				
		    $logger->debug("Node.js server token validation result: $is_valid");

                    if ($@) {
                        $logger->error("CAPTCHA: Failed to parse JSON response: $@");
                    }
                } else {
                    $logger->error("CAPTCHA: Node server unreachable or returned error: " . $response->status_line);
                }
            }

            # Handle the validation result
            if (!$is_valid) {
                $logger->warn("CAPTCHA: Invalid, missing, or expired token for IP: " . $c->request->address);
                
                # Redirect back to the portal index with the error flag for JS to catch
                $c->response->redirect($c->uri_for('/', { error => 'captcha_failed' })->as_string);
                
                # Return immediately to stop Catalyst from processing the registration
                return; 
            } else {
                $logger->info("CAPTCHA: Successfully verified token for IP: " . $c->request->address);
            }
        }

        # If CAPTCHA passed, or if it's any other route, hand it back to PacketFence
        return $orig_dispatch->($c, @args);
    };

# sample constant
#Readonly::Scalar our $GUEST_SESSION_DURATION => 60 * 60 * 24 * 7; # read 7 days

=head1 SUBROUTINES

=over

=item categorization sample

WARNING: The technique described below is for demonstration purposes only.
Node categorization is better performed by the authentication modules under
conf/authentication now. See L<pf::web::auth> for more information.

Here if a particular session variable was set, we categorize the node as a guest
and we set it's expiration to now + $GUEST_SESSION_DURATION.
Then the normal registration code is called.

To set the particular session variable use the following:
 $session->param("usercategory", "guest");

=cut

=item inject variables for templates

Here's an example to make variables accessible to the templates globally.

Also remember that you can always use the $portalSession->stash to add
variables from every location in the code (CGI's, pf::web, etc.). It's
probably the best approach if what you want to inject depend on some state
or user input.

=cut

#*pf::web::stash_template_vars = sub {
#    my ($portalSession, $template) = @_;
#    return { 'helpdesk_phone' => '514-555-1337' };
#};


# If you want to redefine pf::web::guest methods, remember to place yourself in that package with:
#package pf::web::guest;
# and also to redefine in pf::web::guest::... not pf::web::...

# end of no warnings 'redefine' block

}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2025 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

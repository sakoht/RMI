class RMI::Server::ForkedPipes < RMI::Server
    attr_accessor :peer_pid

=begin

=pod

=head1 NAME

RMI::Server::ForkedPipes - service RMI::Client::ForkedPipes requests

=head1 VERSION

This document describes RMI::Server::ForkedPipes v0.11.

=head1 SYNOPSIS

This is used internally by RMI::Client::ForkedPipes.  When constructed
the client makes a private server of this class in a forked process.  

$client->peer_pid eq $client->remote_eval('$$');

$server->peer_pid eq $server->remtoe_eval('$$');

=head1 DESCRIPTION

This subclass of RMI::Server is used by RMI::Client::ForkedPipes when it
forks a private server for itself.

=head1 SEE ALSO

B<RMI>, B<RMI::Client::ForkedPipes>, B<RMI::Server>

=head1 AUTHORS

Scott Smith <sakoht@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2012 Scott Smith <sakoht@cpan.org>  All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this
module.

=cut
=end

end

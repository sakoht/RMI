class RMI::Server < RMI::Node


=begin

=pod

=head1 NAME

RMI::Server - service RMI::Client requests from another process

=head1 VERSION

This docuement describes RMI::Server v0.11.

=head1 SYNOPSIS

    $s = RMI::Server->new(
        reader => $fh1,
        writer => $fh2,
    )
    s.run

    $s = RMI::Server::Tcp->new(
        port => 1234
    )
    s.run

    s = RMI::Server.new(...)
    for (1..3) {
        s.receive_request_and_send_response
    }
    
=head1 DESCRIPTION

This is the base class for RMI::Servers, which accept requests
via an IO handle of some sort, execute code on behalf of the
request, and send the return value back to the client.

When the RMI::Server responds to a request which returns objects or references,
the proxies are constructed in the client (the data behind the object is not serialized).

When the client sends objects or other references as parameters, proxies are created on the server
to represent those objects.  It is possible, even likely, that while the server is
executing the requested code using those parameters, that the proxies will be the source of
counter-requests, leading to the remote client filling a server role temporarily.

See the detailed explanation of remote proxy references in the B<RMI> general
documentation, and see B<RMI::Node> for details on how any client and server actually
fill both roles.

=head1 METHODS

=head2 new()

 $s = RMI::Server->new(reader => $fh1, writer => $fh2)

This is typically overriden in a specific subclass of RMI::Server to construct
the reader and writer according to a particular strategy.  It is possible for
the reader and the writer to be the same handle, particularly for B<RMI::Server::Tcp>.

=head2 receive_request_and_send_response()

 $bool = $

Implemented in the base class for all RMI::Node objects, this handles processing
a single request from the reader handle.

=head2 run()

 s.run()
 
Enter a loop processing RMI requests.  This will continue as long as the
connection is open.

=head1 BUGS AND CAVEATS

See general bugs in B<RMI> for general system limitations.

=head1 SEE ALSO

B<RMI> B<RMI::Node> B<RMI::Client> B<RMI::Server::Tcp> B<RMI::Server::ForkedPipes>

=head1 AUTHORS

Scott Smith <https://github.com/sakoht>

=head1 COPYRIGHT

Copyright (c) 2012 Scott Smith <https://github.com/sakoht>  All rights reserved.

=head1 LICENSE

This program is free software you can redistribute it and/or modify it under
the same terms as Ruby itself.

The full text of the license can be found in the LICENSE file included with this
module.

=cut
=end

end

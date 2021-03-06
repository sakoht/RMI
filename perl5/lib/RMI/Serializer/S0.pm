package RMI::Serializer::S0;
use strict;
use warnings;

sub serialize {
    my ($self, $message_type, $encoded_message_data, $received_and_destroyed_ids) = @_;
    
    unshift @$encoded_message_data, $received_and_destroyed_ids;
    
    my $serialized_blob = Data::Dumper->new([[
            $message_type,
            @$encoded_message_data
    ]])->Terse(1)->Indent(0)->Useqq(1)->Dump;
    
    print "$RMI::DEBUG_MSG_PREFIX N: $$ $message_type serialized as $serialized_blob\n" if $RMI::DEBUG;    
    
    return $serialized_blob;
}

sub deserialize {
    my ($self, $serialized_blob) = @_;

    my $encoded_message_data = eval "no strict; no warnings; $serialized_blob";
    if ($@) {
        die "Exception de-serializing message: $@";
    }        

    my $message_type = shift @$encoded_message_data;
    if (! defined $message_type) {
        die "unexpected undef type from incoming message:" . Data::Dumper::Dumper($encoded_message_data);
    }    

    my $received_and_destroyed_ids = shift @$encoded_message_data;
    
    return ($message_type, $encoded_message_data, $received_and_destroyed_ids);    
}

1;

__END__

=pod

=head1 NAME

RMI::Serializer::S0 - a human-readable JSON serialization protocol

=head1 SYNOPSIS

$c = RMI::Client::ForkedPipes->new(serialization_protocol => 'v1');

=head1 DESCRIPTION

This is the default serialization protocol for RMI in Perl.  It uses
the Data::Dumper module to create a message stream which dumps the arrayref
of message data onto one line of eval-able text which will reconstitute the
data structure.

The use of Data::Dumper here is pure laziness.  The encoded message data list
contains no references, and could be turned into a string with something simpler
than data dumper.

=cut

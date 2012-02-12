class RMI::Serializer::S1 < RMI::Serializer

@@PROTOCOL_VERSION = 1
@@PROTOCOL_SYM = '[' 

require "yaml"

def serialize(sproto, eproto, rproto, message_type, encoded_message_data, received_and_destroyed_ids)
    a = [ 
        sproto, eproto, rproto,
        message_type,
        received_and_destroyed_ids.length
    ] + received_and_destroyed_ids + encoded_message_data

    s = ''
    a.each do |v|
        if s == ''
            s = '['
        else
            s += ', '
        end
        if v.kind_of?(String)
            s += "'" + v + "'"
        else
            s += v.to_s
        end
    end
    s += ']'
    serialized_blob = s

    $RMI_DEBUG && print("#{$RMI_DEBUG_MSG_PREFIX} N: #{$$} #{message_type} serialized as #{serialized_blob}\n") 
    
    return serialized_blob
end

def deserialize(serialized_blob) 

    sym = serialized_blob[0..0]
    #serialized_blob = serialized_blob[1..-1]

    unless sym == @@PROTOCOL_SYM
        version = (@@PROTOCOL_SYM  == '[' ? 1 : sym[0])
        version_sym = version[0];
        raise IOError, "Got message with sym #{sym} protocol #{version} (symbol #{version_sym}), expected #{@@PROTOCOL_VERSION} (symbol #{@@PROTOCOL_SYM}) !!"
    end

    $RMI_DEBUG && print("#{$RMI_DEBUG_MSG_PREFIX} N: #{$$} serialized blob is #{serialized_blob}\n") 
    
    encoded_message_data = eval serialized_blob

    $RMI_DEBUG && print("#{$RMI_DEBUG_MSG_PREFIX} N: #{$$} encoded data #{encoded_message_data}\n") 
    
    sproto = encoded_message_data.shift
    eproto = encoded_message_data.shift
    rproto = encoded_message_data.shift
   
    message_type = encoded_message_data.shift
    if message_type == nil
        raise IOError, "unexpected undef type from incoming message:" . Data::Dumper::Dumper(encoded_message_data)
    end

    received_and_destroyed_ids_count = encoded_message_data.shift.to_i
    received_and_destroyed_ids = []
    received_and_destroyed_ids_count.times do 
        id = encoded_message_data.shift
        received_and_destroyed_ids.push(id)
    end

    $RMI_DEBUG && print("#{$RMI_DEBUG_MSG_PREFIX} N: #{$$} encoded data after shifting #{encoded_message_data}\n") 
    

    return sproto, eproto, rproto, message_type, encoded_message_data, received_and_destroyed_ids
end

=begin

=pod

=head1 NAME

RMI::Serializer::S2 - a human-readable and depthless serialization protocol

=head1 SYNOPSIS

c = RMI::Client::ForkedPipes.new(serialization_protocol => 'v2')

=head1 DESCRIPTION

All serialization protocol modules take an array of simple text strings and
turn them into a blob which can be transmitted to another process and reconstructed.
It is the lowest-level part of the protocol stack in RMI.  The layer above,
the encoding, turns complex objects into strings and back.

The serialization protocol version of an RMI blob is identified by the first byte
of the serialized message.  For this version it is the unprintable ascii value for 2.

This is the default serialization protocol for RMI in Perl.  It uses
the Data::Dumper module to create a message stream which dumps the arrayref
of message data onto one line of eval-able text which will reconstitute the
data structure.  

By using double-quoted strings, newlines are removed from any message, leading 
to a simple blob format of readable characters with one message per line, and easy 
debugging.  The message is itself eval-able in Perl, Python, Ruby and JavaScript.

The use of Data::Dumper here is pure laziness.  The encoded message data list
contains no references, and could be turned into a string with something simpler
than data dumper.


=cut
=end

end

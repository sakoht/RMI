#!/usr/bin/env ruby 

require "rmi"
require "test/unit"

class Test99 < Test::Unit::TestCase
    def test_node_constructor_params
        assert_nothing_raised do
            n1 = RMI::Node.new(:writer => 123)
        end
        
        assert_raise ArgumentError do
            n2 = RMI::Node.new(:junk => 123)
        end 
        
        assert_raise ArgumentError do
            n2 = RMI::Node.new(:local_language => 'perl')
        end
    end

    def test_default_properties
        n3 = RMI::Node.new(:remote_language => 'perl5')
        assert_equal(n3.local_language, 'ruby');
        assert_equal(n3.remote_language, 'perl5');
    end
end


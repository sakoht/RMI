#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 27;
use IO::Handle;     # thousands of lines just for autoflush :−(

use_ok("RMI");
use_ok("RMI::Client");

my $c = RMI::Client->new("fork/pipes");
my $pid = $c->{server_pid};
my $reader = $c->{reader};
my $writer = $c->{writer};
my $sent = $c->{sent};
my $received = $c->{received};

my @result;
my $result;

diag("basic remote function attempt 1");
@result = RMI::call($writer, $reader, $sent, $received, undef, 'main::f1', 2, 3); 
is($result[0], $pid, "retval indicates the method was called in the child/server process");
is($result[1], 5, "result value $result[1] is as expected for 2 + 3");
is(scalar(keys(%$sent)), 0, "no sent objects");
is(scalar(keys(%$received)), 0, "no received objects");

diag("basic remote function attempt 2");
@result = RMI::call($writer, $reader, $sent, $received, undef, 'main::f1', 6, 7);
is($result[1], 13, "result value $result[1] is as expected for 6 + 7");  
is(scalar(keys(%$sent)), 0, "no sent objects");
is(scalar(keys(%$received)), 0, "no received objects");

diag("remote eval");
my $rx = RMI::call($writer, $reader, $sent, $received, undef, "eval", "$$");
diag($rx);

diag("local object call");
my $local1 = RMI::Test::Class1->new(foo => 111);
ok($local1, "made a local object");
@result = $local1->m1();
ok(scalar(@result), "called method locally");
is($result[0], $$, "result value $result[0] matches pid $$");  
is(scalar(keys(%$sent)), 0, "no sent object");
is(scalar(keys(%$received)), 0, "no received objects");

diag("request that remote server do a method call on a local object, which just comes right back");
@result = RMI::call($writer, $reader, $sent, $received, $local1, 'm1');
ok(scalar(@result), "called method remotely");
is($result[0], $$, "result value $result[0] is matches pid $$");  
is(scalar(keys(%$sent)), 1, "one sent object?!"); #"no sent objects b/c this one is gone by the time the method call finishes");
is(scalar(keys(%$received)), 0, "no received objects");

diag("make a remote object");
my $r = RMI::call($writer, $reader, $sent, $received, 'RMI::Test::Class1', 'new');
ok($r, "got an object");
isa_ok($r,"RMI::ProxyObject") or diag(Data::Dumper::Dumper($r));
is(scalar(keys(%$sent)), 1, "one sent object");
is(scalar(keys(%$received)), 1, "one received objects");

diag("call methods on the remote object");

@result = $r->m2(8);
is($result[0], 16, "return values is as expected for remote object with primitive params");

@result = $r->m3($local1);
is($result[0], $$, "return values are as expected for remote object with local object params");

my ($r2) = RMI::call($writer, $reader, $sent, $received, 'RMI::Test::Class1', 'new');
ok($r2, "made another remote object to use for a more complicated method call");
@result = $r->m3($r2);
ok($result[0] != $$, "return value is as expected for remote object with remote object params");

$result = $r->m4($r2,$local1);
ok($result =~ /.$$.$$/, "result $result has other process id, and this process id ($$) 2x");

close $reader; close $writer;
waitpid($pid,0);
exit;


# these may be called from the client or server
sub f1 {
    my ($v1,$v2) = @_;
    return($$, $v1+$v2);
}

sub f2 {
    my ($v1, $v2, $s, $r) = @_;
}

package RMI::Test::Class1;

sub new {
    my $class = shift;
    return bless { pid => $$, @_ }, $class;
}

sub m1 {
    my $self = shift;
    return $self->{pid};
}

sub m2 {
    my $self = shift;
    my $v = shift;
    return($v*2);
}

sub m3 {
    my $self = shift;
    my $other = shift;
    $other->m1;
}

sub m4 {
    my $self = shift;
    my $other1 = shift;
    my $other2 = shift;
    my $p1 = $other1->m1;
    my $p2 = $other2->m1;
    my $p3 = $other1->m3($other2);
    return "$p1.$p2.$p3";
}



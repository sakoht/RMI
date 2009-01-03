
package RMI::TestClass1;
use Scalar::Util;

my %obj_this_process;

sub new {
    my $class = shift;
    my $self = bless { pid => $$, @_ }, $class;
    $obj_this_process{$self} = $self;
    Scalar::Util::weaken($obj_this_process{$self});
    return $self;
}

sub DESTROY {
    my $self = shift;
    delete $obj_this_process{$self};
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

sub dummy_accessor {
    my $self = shift;
    if (@_) {
        $self->{m5} = shift;
    }
    return $self->{m5};
}

sub create_and_return_arrayref {
    my $self = shift;
    my $a = $self->{last_arrayref} = [@_];
    Scalar::Util::weaken($self->{last_arrayref});
    return $a;
}

sub last_arrayref {
    my $self = shift;
    return $self->{last_arrayref};    
}

sub last_arrayref_as_string {
    my $self = shift;
    my $s = join(":", @{ $self->{last_arrayref} });
    return $s;
}

sub create_and_return_hashref {
    my $self = shift;
    my $a = $self->{last_hashref} = {@_};
    Scalar::Util::weaken($self->{last_hashref});
    return $a;
}

sub last_hashref_as_string {
    my $self = shift;
    my $s = join(":", map { $_ => $self->{last_hashref}{$_} } sort keys %{ $self->{last_hashref} });
    return $s;
}

sub create_and_return_scalarref {
    my $self = shift;
    my $s = shift;
    my $r = $self->{last_scalarref} = \$s;
    Scalar::Util::weaken($self->{last_scalarref});
    return $r;
}

sub last_scalarref_as_string {
    my $self = shift;
    return ${$self->{last_scalarref}};
}

1;
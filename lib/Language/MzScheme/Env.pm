package Language::MzScheme::Env;
@_p_Scheme_Env::ISA = __PACKAGE__;

use vars '%Objects';
use strict;
use constant S => "Language::MzScheme";

sub eval {
    my $self = shift;
    my $obj = UNIVERSAL::isa($_[0], S."::Object")
        ? S->eval($_[0], $self)
        : S->eval_string_all($_[0], $self, 1);
    $Objects{+$obj} ||= $self if ref($obj);
    return $obj;
}

sub define {
    my ($self, $name, $code) = @_;
    my $obj = $self->lambda($code);
    S->add_global($name, $obj, $self);
    return $self->lookup($name);
}

sub lambda {
    my ($self, $code) = @_;
    my $obj = UNIVERSAL::isa($code, 'CODE')
        ? S->make_perl_prim_w_arity($code, "$code", 0, -1)
        : S->make_perl_object_w_arity($code, "$code", 0, -1);
    $Objects{+$obj} ||= $self;
    return $obj;
}

sub apply {
    my ($self, $name) = splice(@_, 0, 2);
    @_ = map S->from_perl_scalar($_), @_;
    my $obj = S->apply($self->lookup($name), 0+@_, \@_);
    $Objects{+$obj} ||= $self if ref($obj);
    return $obj;
}

sub lookup {
    my ($self, $name) = @_;

    return $name if UNIVERSAL::isa($name, S.'::Object') and $name->isa('CODE');

    my $sym = S->intern_symbol($name);
    my $obj = S->lookup_global($sym, $self);
    $Objects{+$obj} ||= $self;
    return $obj;
}

1;

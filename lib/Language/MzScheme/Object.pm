package Language::MzScheme::Object;
@_p_Scheme_Object::ISA = __PACKAGE__;

use strict;
use vars '%Proc';
use constant S => "Language::MzScheme";
use overload (
    'bool'      => \&to_bool,
    '""'        => \&to_string,
    '0+'        => \&to_number,
    '='         => \&to_lvalue,
    '&{}'       => \&to_coderef,
    '%{}'       => \&to_hashref,
    '@{}'       => \&to_arrayref,
    '*{}'       => \&to_globref,
    '${}'       => \&to_scalarref,
    '<>'        => \&read,
    fallback    => 1,
);

foreach my $proc (qw( car cdr cadr caar cddr )) {
    no strict 'refs';
    my $code = S."::SCHEME_\U$proc";
    *$proc = sub { $_[0]->bless($code->($_[0])) };
}

foreach my $proc (qw( caddr read write )) {
    no strict 'refs';
    my $code = S."::scheme_$proc";
    *$proc = sub { $_[0]->bless($code->($_[0])) };
}

foreach my $proc (qw( read-char write-char )) {
    no strict 'refs';
    my $sym = $proc;
    $sym =~ s/\W/_/g;
    *$sym = sub { $_[0]->apply($proc, $_[0]) };
}

foreach my $proc (qw( eval apply lambda lookup )) {
    no strict 'refs';
    *$proc = sub {
        my $env = shift(@_)->env;
        $env->can($proc)->($env, @_);
    };
}

sub to_bool {
    my $self = shift;
    !(S->VOIDP($self) || S->FALSEP($self));
}

sub to_string {
    my $self = shift;
    S->STRSYMP($self) ? S->STRSYM_VAL($self) :
    S->CHARP($self)   ? S->CHAR_VAL($self) :
    (S->VOIDP($self) || S->FALSEP($self)) ? '' :
                        $self->as_display;
}

sub to_number {
    my $self = shift;
    (S->VOIDP($self) || S->FALSEP($self)) ? 0 : $self->as_display;
}

sub env {
    my $self = shift;
    $Language::MzScheme::Env::Objects{+$self}
        or die "Cannot find associated environment";
}

sub bless {
    my ($self, $obj) = @_;
    $Language::MzScheme::Env::Objects{+$obj}||=
        $Language::MzScheme::Env::Objects{+$self} if defined $obj;
    return $obj;
}

sub to_coderef {
    my $self = shift;

    S->PROCP($self) or die "Value $self is not a CODE";

    $Proc{+$self} ||= sub { $self->apply($self, @_) };
}

my $Cons;
sub to_hashref {
    my $self = shift;
    my $alist = (S->HASHTP($self)) ? $self->apply(
        'hash-table-map',
        $self,
        $Cons ||= $self->lookup('cons'),
    ) : $self;
    
    my %rv;
    while (my $obj = $alist->car) {
        $rv{$obj->car} = $obj->cdr;
        $alist = $alist->cdr;
    }
    return \%rv;
}

sub to_arrayref {
    my $self = shift;

    if (S->VECTORP($self)) {
        return [ map $self->bless($_), @{S->VEC_BASE($self)} ];
    }

    return [
        map +($self->car, $self = $self->cdr)[0],
            1..S->proper_list_length($self)
    ];
}

sub to_scalarref {
    my $self = shift;
    return \S->BOX_VAL($self);
}

sub as_display {
    my $self = shift;
    my $out = S->make_string_output_port;
    S->display($self, $out);
    return S->get_string_output($out);
}

sub as_write {
    my $self = shift;
    my $out = S->make_string_output_port;
    S->display($self, $out);
    return S->get_string_output($out);
}

sub as_perl_data {
    my $self = shift;

    if ( $self->isa('CODE') ) {
        return $self->to_coderef;
    }
    elsif ( $self->isa('HASH') and !S->NULLP($self) ) {
        my $hash = $self->to_hashref;
        $hash->{$_} = $hash->{$_}->as_perl_data for keys %$hash;
        return $hash;
    }
    elsif ( $self->isa('ARRAY') ) {
        return [ map $_->as_perl_data, @{$self->to_arrayref} ];
    }
    elsif ( $self->isa('GLOB') ) {
        return $self; # XXX -- doesn't really know what to do
    }
    elsif ( $self->isa('SCALAR') ) {
        return \${$self->to_scalarref}->as_perl_data;
    }
    else {
        $self->to_string;
    }
}

sub isa {
    my ($self, $type) = @_;
    ($type eq 'CODE')   ? S->PROCP($self) :
    ($type eq 'HASH')   ? S->HASHTP($self)  || $self->is_alist :
    ($type eq 'ARRAY')  ? S->LISTP($self)   || S->VECTORP($self) :
    ($type eq 'GLOB')   ? S->INPORTP($self) || S->OUTPORTP($self) :
    ($type eq 'SCALAR') ? S->BOXP($self)    :
    $self->SUPER::isa($type);
}

sub is_alist {
    my $self = shift;
    S->NULLP($self) || (
        S->PAIRP($self) &&
        S->PAIRP($self->car) &&
        !S->LISTP($self->caar) &&
        (!S->PAIRP($self->car->cdr) || S->NULLP($self->car->cdr->cdr)) &&
        $self->cdr->is_alist
    );
}

1;

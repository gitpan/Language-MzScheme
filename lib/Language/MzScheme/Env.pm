package Language::MzScheme::Env;
@_p_Scheme_Env::ISA = __PACKAGE__;

use vars '%Objects';
use strict;
use constant S => "Language::MzScheme";

foreach my $sym (qw(
    perl_do perl_eval perl_require perl_use perl_no
)) {
    no strict 'refs';
    my $proc = $sym;
    $proc =~ tr/_/-/;
    *$sym = sub {
        my $self = shift;
        $self->apply($proc, @_);
    };
}

sub eval {
    my $self = shift;
    my $obj = UNIVERSAL::isa($_[0], S."::Object")
        ? S->do_eval($_[0], $self)
        : S->do_eval_string_all($_[0], $self, 1);
    $Objects{S->REFADDR($obj)} ||= $self if ref($obj);
    return $obj;
}

sub define {
    my ($self, $name, $code, $sigil) = @_;

    $code ||= $name;
    $sigil ||= substr($name, -1) if $name =~ /['!?\@\$\%]$/;

    my $obj = $self->lambda($code, $sigil);

    S->add_global($name, $obj, $self);
    return $self->lookup($name);
}

sub lambda {
    my ($self, $code, $sigil) = @_;
    my $name = "$code";
    $name .= ":$sigil" if $sigil;

    my $obj = UNIVERSAL::isa($code, 'CODE')
        ? S->make_perl_prim_w_arity($code, "$name", 0, -1, $sigil)
        : S->make_perl_object_w_arity($code, "$name", 1, -1, $sigil);

    $Objects{S->REFADDR($obj)} ||= $self;
    return $obj;
}

sub apply {
    my ($self, $name) = splice(@_, 0, 2);
    @_ = map S->from_perl_scalar($_), @_;
    my $obj = S->do_apply($self->lookup($name), 0+@_, \@_);
    $Objects{S->REFADDR($obj)} ||= $self if ref($obj);
    return $obj;
}

sub lookup {
    my ($self, $name) = @_;

    return $name if UNIVERSAL::isa($name, S.'::Object') and $name->isa('CODE');

    my $sym = S->intern_symbol($name);
    my $obj = S->lookup_global($sym, $self);
    $Objects{S->REFADDR($obj)} ||= $self;
    return $obj;
}

sub define_perl_wrappers {
    my $self = shift;
    my $require = sub { $self->_wrap_require(@_) };
    $self->define('perl-do', sub { do $_[0] });
    $self->define('perl-eval', sub { eval "@_" });
    $self->define('perl-no', $require); # XXX unimport
    $self->define('perl-use', sub {
        no strict 'refs';
        my $pkg = $require->(@_); shift;

        # XXX - should export using a fake package instead
        @_ = @{"$pkg\::EXPORT"} if !@_ and UNIVERSAL::isa($pkg, 'Exporter');

        foreach my $sym (map { $_->isa('ARRAY') ? @$_ : $_ } @_) {
            my $code = $pkg->can($sym) or next;
            $self->define($sym, $code);
        }

        foreach my $sym (sort keys %{"$pkg\::"}) {
            my $code = *{${"$pkg\::"}{$sym}}{CODE} or next;
            $sym =~ tr/_/-/;
            $self->define("$pkg\::$sym", $code);
            $self->define($sym, $code);
        }

        return $pkg;
    });
    $self->define('perl-require', $require);
    # XXX current-command-line-arguments
}

sub _wrap_require {
    my $self = shift;
    my $pkg = shift;
    $pkg =~ s{::}{/}g;
    $pkg .= ".pm" if index($pkg, '.') == -1;
    require $pkg;
    $pkg =~ s{/}{::}g;
    $pkg =~ s{\.pm$}{}i;
    $self->define($pkg);
    return $pkg;
}

1;

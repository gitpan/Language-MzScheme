package Language::MzScheme;
$Language::MzScheme::VERSION = '0.05';

use strict;
use vars qw(@EXPORT @EXPORT_OK %EXPORT_TAGS);
use Language::MzScheme_in;
use Language::MzScheme::Env;
use Language::MzScheme::Object;

BEGIN {
    @EXPORT_OK = @EXPORT;
    @EXPORT = ();
    %EXPORT_TAGS = ( all => \@EXPORT_OK );
}

=head1 NAME

Language::MzScheme - Perl bindings to PLT MzScheme

=head1 VERSION

This document describes version 0.05 of Language::MzScheme, released
June 13, 2004.

=head1 SYNOPSIS

    use Language::MzScheme;
    my $env = Language::MzScheme->new;
    my $obj = $env->eval('(+ 1 2)');

    # See t/*.t in the source distribution for more!

=head1 DESCRIPTION

This module provides Perl bindings to PLT's MzScheme language.

The documentation is sorely lacking at this moment.  For an overview of
supported features, please consult F<t/*.t> in the source distribution.

=cut

sub new {
    my $self = shift;
    my $env = $self->basic_env;
    $env->define_perl_wrappers;
    return $env;
}

if (!$Language::MzScheme::Initialized) {
    no strict 'refs';
    if (defined &mzscheme_init) {
        mzscheme_init();
        $Language::MzScheme::scheme_case_sensitive = 1;
    }

    foreach my $func (@EXPORT_OK) {
        my $idx = index(lc($func), 'scheme_');
        $idx > -1 or next;
        my $sym = substr($func, $idx + 7);
        *$sym = sub { shift; goto &$func }
            unless defined &$sym or defined $$sym;
    }

    foreach my $func (@EXPORT_OK) {
        my $idx = index(lc($func), 'mzscheme_');
        $idx > -1 or next;
        my $sym = substr($func, $idx + 9);
        *$sym = sub { shift; goto &$func }
            unless defined &$sym or defined $$sym;
    }

    $Language::MzScheme::Initialized++;
}

1;

=head1 SEE ALSO

L<Inline::MzScheme>, L<http://plt-scheme.org/software/mzscheme/>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

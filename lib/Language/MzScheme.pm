package Language::MzScheme;
$Language::MzScheme::VERSION = '0.01';

use strict;
use Language::MzScheme_in;

=head1 NAME

Language::MzScheme - Perl bindings to PLT MzScheme

=head1 VERSION

This document describes version 0.00_01 of Language::MzScheme, released
June 7, 2004.

=head1 SYNOPSIS

    use strict;
    use Language::MzScheme;
    my $env = scheme_basic_env();
    my $out = scheme_get_param($scheme_config, $MZCONFIG_OUTPUT_PORT);
    my $val = scheme_eval_string('(+ 1 2)', $env);
    scheme_display($val, $out);
    scheme_display(scheme_make_char("\n"), $out);

=head1 DESCRIPTION

This module provides Perl bindings to PLT's MzScheme language.

Currently, it simply exports all C enums, functions and symbols found in
the MzScheme's extension table into Perl space, without any further
processing.

Object-oriented wrappers and Perl-based primitives are planned for the
next few versions.

=cut

1;

=head1 SEE ALSO

L<http://plt-scheme.org/software/mzscheme/>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Best Practical Solutions, LLC.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

#!/usr/bin/perl

use strict;
use Test;
use FindBin;
use Language::MzScheme ':all';

BEGIN { plan tests => 5 }

my $env = scheme_basic_env();
ok(eval_scheme('(+ 1 2)'), 3);

sub perl_hello { (Hello => reverse map eval_scheme($_), @_) };
my $prim = mzscheme_make_perl_prim_w_arity(\&perl_hello, "perl:procedure", 0, -1);
scheme_add_global('perl-hello', $prim, $env);

ok(eval_scheme('perl-hello'), '#<primitive:perl:procedure>');
ok(eval_scheme('(car (perl-hello "Scheme" "Perl"))'), 'Hello');
ok(eval_scheme('(cadr (perl-hello "Scheme" "Perl"))'), 'Perl');
ok(eval_scheme('(caddr (perl-hello "Scheme" "Perl"))'), 'Scheme');

sub eval_scheme {
    my $out = scheme_make_string_output_port();
    my $val = (
        UNIVERSAL::isa($_[0], '_p_Scheme_Object')
            ? scheme_eval($_[0], $env)
            : scheme_eval_string($_[0], $env)
    );
    scheme_display($val, $out);
    return scheme_get_string_output($out);
}

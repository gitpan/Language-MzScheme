#!/usr/bin/perl

use strict;
use Language::MzScheme;

my $env = scheme_basic_env();
my $out = scheme_get_param($scheme_config, $MZCONFIG_OUTPUT_PORT);
my $val = scheme_eval_string('(+ 1 2)', $env);
scheme_display($val, $out);
scheme_display(scheme_make_char("\n"), $out);

#!/usr/bin/perl

use strict;
use Config;
use inc::Module::Install;

name('Language-MzScheme');
version_from('lib/Language/MzScheme.pm');
abstract_from('lib/Language/MzScheme.pm');
author('Autrijus Tang <autrijus@autrijus.org>');
license('perl');
can_cc() or die "This module requires a C compiler";

`swig -ldflags` =~ /\w/
  or die "This module requires SWIG - http://www.swig.org/";
`mzscheme --version` =~ /\d/
  or die "This module requires MzScheme - http://plt-scheme.org/software/mzscheme/";

my $plt_path = $ENV{PLT_PATH} || do {
    my $show = `mzc --ldl-show --help`
      or die 'Cannot run mzc; please set $ENV{PLT_PATH}';
    $show =~ m!\("([^"]+)/lib/!i
      or die 'Cannot find PLT path; please set $ENV{PLT_PATH}';
    $1;
};

my $include = "$plt_path/include";
-d $include or die "Cannot find 'include' dir under $plt_path; please set \$ENV{PLT_PATH}";

make_hi();

system(
    'swig',
    "-I$include",
    qw(-module Language::MzScheme -includeall -exportall -perl5 mzscheme.i)
);

rename("MzScheme.pm" => "lib/Language/MzScheme_in.pm");

makemaker_args(
    LIBS => "-L$plt_path/lib -lmzgc -lmzscheme",
    INC => "-I$include",
    OBJECT => "mzscheme_wrap$Config{obj_ext}",
);

WriteAll( sign => 1 );

sub make_hi {
    local $/ = ";\n";

    open IN, "$include/scheme.h" or die $!;
    open OUT, "> scheme.hi" or die $!;
    while (<IN>) {
        s/.*?^enum\b/enum/ms or next;
        print OUT $_, "\n";
    }
    close OUT;
    close IN;

    open IN, "$include/schemef.h" or die $!;
    open OUT, "> schemef.hi" or die $!;
    while (<IN>) {
        /(.*)^MZ_EXTERN\s*(.+)/sm or next;
        $_ = "$1$2"; s/MZ_EXTERN\s*//g;
        print OUT $_, "\n";
    }
    close OUT;
    close IN;
}

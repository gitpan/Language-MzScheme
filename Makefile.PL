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

if (-e "lib/Language/MzScheme_in.pm" and !$ENV{SWIG_REBUILD}) {
    print "Using existing lib/Language/MzScheme_in.pm.\n";
    print "(To regenerate it, setenv SWIG_REBUILD=1 and rerun Makefile.PL.)\n";
    unlink 'MzScheme.pm';
}
else {
    rename('MzScheme.pm' => 'lib/Language/MzScheme_in.pm');
}

makemaker_args(
    LIBS => "-L$plt_path/lib -lmzgc -lmzscheme",
    INC => "-I$include",
    OBJECT => "mzscheme_wrap$Config{obj_ext}",
);

WriteAll( sign => 1 );

sub make_hi {
    open IN, "$include/scheme.h" or die $!;
    open OUT, "> mzscheme_wrap.h" or die $!;
    while (<IN>) {
        next if /^#include\b/;
        next if /typedef struct Scheme_Jumpup_Buf \{/ .. /\} Scheme_Jumpup_Buf/;
        next if /typedef struct Scheme_Thread \{/ .. /\} Scheme_Thread/;
        next if /^MZ_EXTERN/;
        print OUT $_;
    }
    close OUT;
    close IN;

    open IN, "$include/schemex.h" or die $!;
    open OUT, ">> mzscheme_wrap.h" or die $!;
    while (<IN>) {
        next if /^#include\b/;
        next if /^typedef struct \{/;
        next if /^\} Scheme_Extension_Table;/;
        s/\(\*(\w+)\)/$1/;
        print OUT $_;
    }
    close OUT;
    close IN;
}

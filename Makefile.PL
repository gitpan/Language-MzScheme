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

print << ".";
Checking dependencies:
- SWIG v1.3.20 or above - http://www.swig.org/
- MzScheme v200 or above - http://plt-scheme.org/software/mzscheme/
.

`swig -ldflags` =~ /\w/
  or die "SWIG not found, aborting";
`mzscheme --version` =~ /\d/
  or die "MzScheme not found, aborting";

print << ".";
...done.  
(If build fails, please check swig and mzscheme's versions manually.)
.

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
    qw(-module Language::MzScheme -noproxy -includeall -exportall -perl5 mzscheme.i)
);

unlink('lib/Language/MzScheme_in.pm');
rename('MzScheme.pm' => 'lib/Language/MzScheme_in.pm');

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

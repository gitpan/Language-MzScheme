use strict;
use Math::Trig ();
use Test::More tests => 13;

use_ok('Language::MzScheme');

my $env = Language::MzScheme->new;
is($env->perl_use('Math::Trig'), 'Math::Trig', 'perl_use');
is($env->perl_require('Math::Trig'), 'Math::Trig', 'perl_require - with ::');
is($env->perl_require('Math/Trig.pm'), 'Math::Trig', 'perl_require - with /');

is($env->eval('(perl-use Math::Trig)'), 'Math::Trig', 'perl-use');
is($env->eval('(perl-eval "$0")'), $0, 'perl-eval');

ok($env->eval("(Math::Trig 'isa? 'Exporter)"), 'isa? - true');
ok(!$env->eval("(Math::Trig 'isa? 'Exploder)"), 'isa? - false');

ok($env->eval("(Math::Trig 'can? 'pi)"), 'can? - true');
ok(!$env->eval("(Math::Trig 'can? 'pie)"), 'can? - false');

is($env->eval("(GD)"), Math::Trig::GD, 'invocation - import');
is($env->eval("(Math::Trig::GD)"), Math::Trig::GD, 'invocation - full name');
cmp_ok(
    $env->eval("(deg2deg 1792)"),
    '==',
    Math::Trig::deg2deg(1792),
    'invocation - with parameters'
);

#!/usr/bin/perl

use strict;
use Data::Dumper;
use Test::More tests => 43;

use_ok('Language::MzScheme');

my $env = Language::MzScheme->new;

my $sigils = {
    auto    => '',
    bool    => '?',
    void    => '!',
    list    => '@',
    hash    => '%',
    scalar  => '$',
    symbol  => '\'',
};

my $plans = [
    sub { @_ } => [
        [] => {
            auto   => [],       void   => undef,
            bool   => undef,    list   => [],
            scalar => 0,        symbol => 0,
            hash   => {},
        },
        [2] => {
            auto   => 2,        void   => undef,
            bool   => '#t',     list   => [2],
            scalar => 1,        symbol => 1,
            hash   => { 2 => undef },
        },
        [1,2] => {
            auto   => [1,2],    void   => undef,
            bool   => '#t',     list   => [1,2],
            scalar => 2,        symbol => 2,
            hash   => { 1 => 2 },
        },
        ["a","b"] => {
            auto   => ["a","b"],void   => undef,
            bool   => '#t',     list   => ["a","b"],
            scalar => 2,        symbol => 2,
            hash   => { a => "b" },
        },
    ],
    sub { 0 } => [
        [] => {
            auto   => 0,        void   => undef,
            bool   => undef,    list   => [0],
            scalar => 0,        symbol => 0,
            hash   => { 0 => undef },
        },
    ],
    sub { "a", "b" } => [
        [] => {
            auto   => ["a","b"],void   => undef,
            bool   => '#t',     list   => ["a","b"],
            scalar => "b",      symbol => "b",
            hash   => {"a","b"},
        },
    ],
];

my ($sub, $plan);
my $subs = {
    map {
        ($_ => $env->define('perl-list'.$sigils->{$_}, sub { goto &$sub })),
    } keys %$sigils
};

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 0;
$Data::Dumper::Quotekeys = 0;
while (($sub, $plan) = splice(@$plans, 0, 2)) {
    while (my ($input, $output) = splice(@$plan, 0, 2)) {
        foreach my $context (sort keys %$output) {
            my $out = Dumper($output->{$context});
            chomp $out;
            is_deeply(
                $subs->{$context}->(@$input)->as_perl_data,
                $output->{$context},
                "$context context, input: (@$input), output: $out"
            );
        }
    }
}

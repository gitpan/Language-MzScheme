#!/usr/bin/perl

use strict;
use Test;
use FindBin;

BEGIN { plan tests => 1 }

chdir $FindBin::Bin;
ok(`$^X scripts/three.pl`, "3\n");

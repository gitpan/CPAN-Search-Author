#!perl

use strict; use warnings;
use Test::More;
use CPAN::Search::Author;

my ($search, $result);
$search = CPAN::Search::Author->new();
eval { $result = $search->by_id('MANWAR'); };
plan skip_all => "It appears you don't have internet access."
    if ($@ =~ /ERROR\: Couldn\'t connect to search\.cpan\.org/);
is($result, 'Mohammad S Anwar');

eval { $result = $search->where_id_starts_with('1'); };
like($@, qr/ERROR: Invalid letter \[1\]./);

done_testing();
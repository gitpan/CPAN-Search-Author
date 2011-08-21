use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'CPAN::Search::Author',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/CPAN/Search/Author.pm',
    ABSTRACT_FROM => 'lib/CPAN/Search/Author.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'CPAN-Search-Author-*' },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PREREQ_PM     => {
        'Test::More'     => 0,
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'HTML::Entities' => '1.35',
    },
);
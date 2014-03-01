package CPAN::Search::Author;

use strict; use warnings;

use overload q("") => \&as_string, fallback => 1;

=head1 NAME

CPAN::Search::Author - Interface to search CPAN module author.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';
our $DEBUG   = 0;

use Carp;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use HTML::Entities qw/decode_entities/;

=head1 DESCRIPTION

CPAN::Search::Author is an attempt to provide  programmatical interface to CPAN Search engine.
CPAN Search is a search engine for the distributions, modules, docs, and ID's on CPAN.  It was
conceived  and  built by  Graham Barr  as a way to make things easier to navigate.  Originally
named TUCS [ The Ultimate CPAN Search ] it was later named CPAN Search or Search DOT CPAN.

=cut

sub new
{
    my $class = shift;
    my $self  = { _browser => LWP::UserAgent->new() };

    bless $self, $class;
    return $self;
}

=head1 METHODS

=head2 by_id()

This method accepts CPAN ID exactly as provided by CPAN. It does realtime search on  CPAN site
and fetch the author name for the given CPAN ID. However it would croak if it can't access the
CPAN site or unable to get any response for the given CPAN ID.

    use strict; use warnings;
    use CPAN::Search::Author;
    my $search = CPAN::Search::Author->new();
    my $result = $search->by_id('MANWAR');

=cut

sub by_id
{
    my $self     = shift;
    my $id       = shift;

    my $browser  = $self->{_browser};
    $browser->env_proxy;
    my $request  = HTTP::Request->new(POST=>qq[http://search.cpan.org/search?query=$id&mode=author]);
    my $response = $browser->request($request);
    print {*STDOUT} "Search By Id [$id] Status: " . $response->status_line . "\n" if $DEBUG;
    croak("ERROR: Couldn't connect to search.cpan.org.\n")
        unless $response->is_success;

    my $contents = $response->content;
    my @contents = split(/\n/,$contents);
    foreach (@contents)
    {
        chomp;
        s/^\s+//g;
        s/\s+$//g;
        if (/\<p\>\<h2 class\=sr\>\<a href\=\"\/\~(.*)\/\"\><b>(.*)<\/b\>/)
        {
            if (uc($id) eq uc($1))
            {
                $self->{result} = decode_entities($2);
                return $self->{result};
            }
        }
    }
    $self->{result} = undef;
    return;
}

=head2 where_id_starts_with()

This  method  accepts an alphabet (A-Z) and get the list of authors that start with the  given
alphabet  from  CPAN site realtime. However it would croak if it can't access the CPAN site or
unable to get any response for the given CPAN ID.

    use strict; use warnings;
    use CPAN::Search::Author;
    my $search = CPAN::Search::Author->new();
    my $result = $search->where_id_starts_with('M');

=cut

sub where_id_starts_with
{
    my $self   = shift;
    my $letter = shift;
    croak("ERROR: Invalid letter [$letter].\n")
        unless ($letter =~ /[A-Z]/i);

    my $browser  = $self->{_browser};
    $browser->env_proxy;
    my $request  = HTTP::Request->new(POST=>qq[http://search.cpan.org/author/?$letter]);
    my $response = $browser->request($request);
    print {*STDOUT} "Search Id Starts With [$letter] Status: " . $response->status_line . "\n" if $DEBUG;
    croak("ERROR: Couldn't connect to search.cpan.org.\n")
        unless $response->is_success;

    my $contents = $response->content;
    my @contents = split(/\n/,$contents);

    my @authors;
    foreach (@contents)
    {
        chomp;
        s/^\s+//g;
        s/\s+$//g;
        if (/<a href\=\"\/\~(.*)\/\"/)
        {
            push @authors, $1;
        }
    }
    return @authors;
}

=head2 where_name_contains()

This  method  accepts  a search string and look for the string in the author's name of all the
CPAN modules realtime and returns the a reference to a hash containing id,name pair containing
the search string. It croaks if unable to access the search.cpan.org.

    use strict; use warnings;
    use CPAN::Search::Author;
    my $search = CPAN::Search::Author->new();
    my $result = $search->where_name_contains('MAN');

=cut

sub where_name_contains
{
    my $self     = shift;
    my $query    = shift;

    my $browser  = $self->{_browser};
    $browser->env_proxy;
    my $request  = HTTP::Request->new(POST=>qq[http://search.cpan.org/search?query=$query&mode=author]);
    my $response = $browser->request($request);
    print {*STDOUT} "Search By Name Contains [$query] Status: " . $response->status_line . "\n" if $DEBUG;
    croak("ERROR: Couldn't connect to search.cpan.org.\n")
        unless $response->is_success;

    my $contents = $response->content;
    my @contents = split(/\n/,$contents);

    my $authors;
    foreach (@contents)
    {
        chomp;
        s/^\s+//g;
        s/\s+$//g;
        if (/\<p\>\<h2 class\=sr\>\<a href\=\"\/\~(.*)\/\"\><b>(.*)<\/b\>/)
        {
            $authors->{$1} = decode_entities($2);
        }
    }
    $self->{result} = $authors;
    return $authors;
}

=head2 as_string()

Return the last search result in human readable format.

    use strict; use warnings;
    use CPAN::Search::Author;
    my $search = CPAN::Search::Author->new();
    my $result = $search->where_name_contains('MAN');
    print $search->as_string();

    # or simply

    print $search;

=cut

sub as_string
{
    my $self = shift;
    return $self->{result} unless ref($self->{result});

    my $string;
    foreach (keys %{$self->{result}})
    {
        $string .= sprintf("%s: %s\n", $_, $self->{result}->{$_});
    }
    return $string;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please   report  any bugs or feature requests to C<bug-cpan-search-author at rt.cpan.org>,  or
through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CPAN-Search-Author>.
I  will  be  notified,  and then you'll automatically be notified of progress on your bug as I
make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CPAN::Search::Author

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CPAN::Search::Author>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CPAN-Search-Author>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CPAN-Search-Author>

=item * Search CPAN

L<http://search.cpan.org/dist/CPAN-Search-Author/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011-14 Mohammad S Anwar.

This  program   is free software; you can redistribute it and/or modify  it under the terms of
either :  the  GNU General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program   is  distributed in the hope that it will be useful, but WITHOUT  ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of CPAN::Search::Author
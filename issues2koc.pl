#!/usr/bin/perl 

# Copyright 2014 Magnus Enger Libriotech

=head1 NAME

issues2koha.pl - Get active issues from Koha and format them as as KOC file.

=head1 SYNOPSIS

 perl issues2koc.pl --branch CPL > cpl-issues.koc
 
 sudo koha-shell -c "perl issues2koc.pl" koha
 
=head1 KOC - HUH? 

L<http://wiki.koha-community.org/wiki/Koha_offline_circulation_file_format>

=cut

use Getopt::Long;
use Data::Dumper;
use Template;
use Pod::Usage;
use Modern::Perl;

use C4::Context;
my $dbh   = C4::Context->dbh();

# Get options
my ( $branch, $limit, $verbose, $debug ) = get_options();

my $query = "
SELECT issues.issuedate      AS issuedate,
       borrowers.cardnumber  AS cardnumber,
       items.barcode         AS barcode
FROM issues, items, borrowers
WHERE issues.itemnumber = items.itemnumber AND 
      issues.borrowernumber = borrowers.borrowernumber
";
my $sth;
if ( $branch ) {
    $query .= " AND items.homebranch = '$branch'";
}
$sth   = $dbh->prepare($query);
$sth->execute();

say "Version=1.0\tGenerator=issues2koc.pl\tGeneratorVersion=0.1";
while ( my $data = $sth->fetchrow_hashref() ) {
    say $data->{issuedate} . "\tissue\t" . $data->{cardnumber} . "\t" . $data->{barcode};
}

=head1 OPTIONS

=over 4

=item B<-b, --branch>

Specify a branch.

=item B<-l, --limit>

Only process the n first issues. Not implemented.

=item B<-v --verbose>

More verbose output. Not implemented.

=item B<-d --debug>

Even more verbose output. Not implemented.

=item B<-h, -?, --help>

Prints this help message and exits.

=back
                                                               
=cut

sub get_options {

    # Options
    my $branch  = '';
    my $limit   = '';
    my $verbose = '';
    my $debug   = '';
    my $help    = '';

    GetOptions (
        'b|branch=s' => \$branch,
        'l|limit=i'  => \$limit,
        'v|verbose'  => \$verbose,
        'd|debug'    => \$debug,
        'h|?|help'   => \$help
    );

    pod2usage( -exitval => 0 ) if $help;

    return ( $branch, $limit, $verbose, $debug );

}

=head1 AUTHOR

Magnus Enger

=head1 LICENSE

This is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

=cut

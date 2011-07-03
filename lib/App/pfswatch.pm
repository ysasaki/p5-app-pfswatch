package App::pfswatch;

use strict;
use 5.008_001;
use Pod::Usage;
use Getopt::Long;
use POSIX qw(:sys_wait_h);
use Filesys::Notify::Simple;
use Regexp::Assemble;

our $VERSION = '0.06';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my $self = shift;

    my %opts = $self->parse_argv(@_);

    if ( $opts{help} or scalar @{ $opts{exec} } == 0 ) {
        pod2usage();
    }

    my @path = $self->argv_to_path( @{ $opts{path} } );
    warn sprintf "Start watching %s\n", join ',', @path unless $opts{quiet};

    my @cmd             = @{ $opts{exec} };
    my $ignored_pattern = $self->ignored_pattern;

    local $| = 1;

LOOP:
    if ( my $pid = fork ) {
        waitpid( $pid, 0 );
        goto LOOP;
    }
    elsif ( $pid == 0 ) {

        # child
        my $watcher = Filesys::Notify::Simple->new( \@path );
        $watcher->wait(
            sub {
                my @events = @_;
                my $exec   = 0;
                for my $e (@events) {
                    warn sprintf "[PFSWATCH_DEBUG] Path:%s\n", $e->{path}
                        if $ENV{PFSWATCH_DEBUG};
                    if ( $e->{path} !~ $ignored_pattern ) {
                        $exec++;
                        last;
                    }
                }
                if ($exec) {
                    warn sprintf "exec %s\n", join ' ', @cmd
                        unless $opts{quiet};
                    exec @cmd or die $!;
                }
            }
        );
    }
    else {
        die "cannot fork: $!";
    }
}

sub argv_to_path {
    my $self = shift;
    my @path = sort @_;
    @path = '.' unless scalar @path > 0;
    return @path;
}

sub parse_argv {
    my $self = shift;
    local @ARGV = @_;

    my $p = Getopt::Long::Parser->new( config => ['pass_through'] );
    $p->getoptions( \my %opts, 'quiet', 'help|h' );

    my ( @path, @cmd );
    my $exec_re = qr/^-(e|-exec)$/i;
    while ( my $arg = shift @ARGV ) {
        if ( $arg =~ $exec_re ) {
            @cmd = splice @ARGV, 0, scalar @ARGV;
        }
        else {
            push @path, $arg;
        }
    }
    $opts{path} = \@path;
    $opts{exec} = \@cmd;

    return %opts;
}

my @DEFAULT_IGNORED = (
    '^.*/\..+$',    # dotfile
);

sub ignored_pattern {
    my $self = shift;

    # TODO read ~/.pfswatchrc and set ignored pattern
    my $ra = Regexp::Assemble->new;
    $ra->add($_) for @DEFAULT_IGNORED;
    return $ra->re;
}
1;
__END__

=head1 NAME

App::pfswatch - a simple utility that detects changes in a filesystem and run given command

=head1 SYNOPSIS

pfswatch [-h] [path ...] -e COMMAND

    --exec | -e COMMAND
        run COMMAND when detects changes in a filesystem under given path.

    --quiet | -q
        run in quiet mode. only print COMMAND output.

    --help | -h 
        show this message.

=head1 EXAMPLE

    $ pfswatch t/ lib/ -e prove -lr t/

=head1 DESCRIPTION

App::pfswatch is a utility that detects changes in a filesystem and run given command.

pfswatch does not detect change of dot files.

=head1 DEBUGGING

If you want to know which file is changed, set C<PFSWATCH_DEBUG=1>.

    $ PFSWATCH_DEBUG=1 pfswatch lib -e ls -l lib

=head1 AUTHOR

Yoshihiro Sasaki E<lt>ysasaki at cpan.orgE<gt>

=head1 SEE ALSO

L<Filesys::Notify::Simple>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 COPYRIGHT

Copyright 2011 Yoshihiro Sasaki All rights reserved.

=cut

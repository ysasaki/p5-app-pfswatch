package App::pfswatch;

use strict;
use 5.008_001;
use Pod::Usage;
use Getopt::Long;
use POSIX qw(:sys_wait_h);
use Filesys::Notify::Simple;
use Regexp::Assemble;
use Carp ();

our $VERSION = '0.06';

sub new {
    my $class = shift;
    my %opts  = @_;
    my %args  = (
        path => _is_arrayref( $opts{path} )
        ? [ sort @{ $opts{path} } ]
        : ['.'],
        exec  => _is_arrayref( $opts{exec} ) ? $opts{exec} : undef,
        quiet => delete $opts{quiet}         ? 1           : 0,
        pipe  => delete $opts{pipe}          ? 1           : 0,
    );

    unless ( $args{exec} ) {
        my $type
            = ref $opts{exec}     ? ref $opts{exec}
            : defined $opts{exec} ? $opts{exec}
            :                       'undef';
        Carp::croak(
            "Mandatory parameter 'exec' does not pass the type constraint because: Validation failed for Array with value $type"
        );
    }

    bless \%args, $class;
}

sub new_with_options {
    my $klass = shift;
    my $class = ref $klass || $klass;

    my %opts = $class->parse_argv(@_);
    if ( $opts{help} or scalar @{ $opts{exec} } == 0 ) {
        pod2usage();
    }

    $class->new(
        path  => $opts{path},
        exec  => $opts{exec},
        quiet => $opts{quiet} ? 1 : 0,
        pipe  => $opts{pipe} ? 1 : 0,
    );
}

sub run {
    my $self = shift;

    my @path = @{ $self->{path} };
    warn sprintf "Start watching %s\n", join ',', @path
        unless $self->{quiet};

    my @cmd             = @{ $self->{exec} };
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
                        unless $self->{quiet};
                    exec @cmd or die $!;
                }
            }
        );
    }
    else {
        die "cannot fork: $!";
    }
}

sub parse_argv {
    my $class = shift;
    local @ARGV = @_;

    my $p = Getopt::Long::Parser->new( config => ['pass_through'] );
    $p->getoptions( \my %opts, 'pipe', 'quiet', 'help|h' );

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

sub _is_arrayref {
    my $v = shift;
    $v && ref $v eq 'ARRAY' && scalar @$v > 0 ? 1 : 0;
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

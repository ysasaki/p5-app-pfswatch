package App::fswatch;

use strict;
use 5.008_001;
use Pod::Usage;
use Getopt::Long;
use POSIX qw(:sys_wait_h);
use Filesys::Notify::Simple;
use Regexp::Assemble;

our $VERSION = '0.02';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my $self = shift;
    local @ARGV = @_;
    local $|    = 1;

    my $ret = GetOptions( \my %opts, 'exec|e=s', 'help|h' );

    if ( $opts{help} or !$opts{exec} ) {
        pod2usage();
    }

    my @path = $self->argv_to_path(@ARGV);
    warn sprintf "Start watching %s\n", join ',', @path;

    my @cmd             = $self->string_to_cmd( $opts{exec} );
    my $ignored_pattern = $self->ignored_pattern;

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
                    warn sprintf "[FSWATCH_DEBUG] Path:%s\n", $e->{path}
                        if $ENV{FSWATCH_DEBUG};
                    if ( $e->{path} !~ $ignored_pattern ) {
                        $exec++;
                        last;
                    }
                }
                if ($exec) {
                    warn sprintf "exec %s\n", join ' ', @cmd;
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

sub string_to_cmd {
    my $self = shift;
    return grep $_, split /\s+/, shift;
}

my @DEFAULT_IGNORED = (
    '^.*/\..+$',       # dotfile
    '^.*/.+\.swp$',    # vim swap file
);

sub ignored_pattern {
    my $self = shift;

    # TODO read ~/.fswatchrc and set ignored pattern
    my $ra = Regexp::Assemble->new;
    $ra->add($_) for @DEFAULT_IGNORED;
    return $ra->re;
}
1;
__END__

=head1 NAME

App::fswatch - watch filesystem changes and run command

=head1 SYNOPSIS

fswatch [-h] [-e COMMAND] [path ...]

    --exec | -e COMMAND
        exec COMMAND if file or directory is created, changed, removed under given path.

    --help | -h 
        show this message.

=head1 EXAMPLE

    $ fswatch t/ lib/ -e 'prove -lr t/'

=head1 DESCRIPTION

App::fswatch is utility for watching file or directory change and run command

=head1 DEBUGGING

If you want to know which file is changed, set C<FSWATCH_DEBUG=1>.

    $ FSWATCH_DEBUG=1 fswatch lib -e 'ls -l lib'

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

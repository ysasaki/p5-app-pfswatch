package App::fswatch;

use strict;
use 5.008_001;
use Pod::Usage;
use Getopt::Long;
use POSIX qw(:sys_wait_h);
use Filesys::Notify::Simple;

our $VERSION = '0.01';

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

    my @path = sort @ARGV;
    @path = '.' unless scalar @path > 0;
    warn sprintf "Start watching %s\n", join ',', @path;

    my @cmd = split /\s/, $opts{exec};

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
                # TODO ignore dot and swap files
                warn sprintf "exec %s\n", join ' ', @cmd;
                exec @cmd or die $!;
            }
        );
    }
    else {
        die "cannot fork: $!";
    }

}

1;
__END__

=head1 NAME

App::fswatch - watch filesystem changes and run command

=head1 SYNOPSIS

fswatch [-h] [-e COMMAND] [path ...]

    --exec | -e COMMAND

    --help | -h 
        show this message

=head1 DESCRIPTION

App::fswatch is utility for watching file or directory change and run command

=head1 AUTHOR

Yoshihiro Sasaki E<lt>ysasaki at cpan.orgE<gt>

=head1 SEE ALSO

L<Filesys::Notify::Simple>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

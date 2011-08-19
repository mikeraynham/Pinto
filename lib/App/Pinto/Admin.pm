package App::Pinto::Admin;

# ABSTRACT: Command-line driver for Pinto

use strict;
use warnings;

use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

  return (

#      [ "config=s"    => "Path to your pinto config file" ],
      [ "repos=s"     => "Path to your repository directory"],
      [ "nocleanup"   => "Do not remove distribtuions that become outdated" ],
      [ "nocolor"     => "Do not colorize diagnostic messages" ],
      [ "nocommit"    => "Do not commit changes to VCS" ],
      [ "noinit"      => "Skip updating or pulling from VCS" ],
      [ "notag"       => "Do not make tag after committing to VCS" ],
      [ "quiet|q"     => "Only report fatal errors"],
      [ "verbose|v+"  => "More diagnostic output (repeatable)" ],
  );
}

#------------------------------------------------------------------------------

sub usage_desc {
    return '%c [global options] <command>';
}

#------------------------------------------------------------------------------

=method pinto( $command_options )

Returns a reference to the L<Pinto> object.  If it does not already
exist, one will be created using the global and command options.

=cut

sub pinto {
    my ($self, $command_options) = @_;

    require Pinto;
    require Pinto::Config;
    require Pinto::Logger;

    return $self->{pinto} ||= do {
        my %global_options = %{ $self->global_options() };
        my $config = Pinto::Config->new(%global_options, %{$command_options});
        my $logger = Pinto::Logger->new(config => $config);
        my $pinto  = Pinto->new(config => $config, logger => $logger);
    };
}

#------------------------------------------------------------------------------

1;

__END__

=pod

=head1 DESCRIPTION

There is nothing to see here.  You probably should look at the
documentation for L<pinto> instead.

=cut

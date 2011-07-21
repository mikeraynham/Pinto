package App::Pinto::Command;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use App::Cmd::Setup -command;

#-----------------------------------------------------------------------------

sub pinto {
  return $_[0]->app();
}

#-----------------------------------------------------------------------------

sub config {
    return $_[0]->app()->config();
}

#-----------------------------------------------------------------------------

1;

__END__

# ABSTRACT: support directory storage for Export action

package Pinto::Action::Export::Directory;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Str);
use MooseX::MarkAsMethods ( autoclean => 1 );

use Try::Tiny;
use Path::Class;

use Pinto::Util qw(mksymlink);
use File::Copy ();

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

with 'Pinto::Action::Export::ExporterRole';

sub insert {
   my ($self, $source, $destination) = @_;

   return if $self->is_present($source);
   $self->mark($source);

   $destination = $self->path()->file($destination);
   _ensure_path($destination->parent());
   File::Copy::copy($source, $destination);
   return;
}

sub link {
   my ($self, $from, $to) = @_;
   $from = $self->path()->file($from);
   _ensure_path($from->parent());
   mksymlink($from, $to);
   return;
}

sub _ensure_path {
   my ($path) = @_;
   $path->mkpath() unless -e $path;
   return;
}

sub close {}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

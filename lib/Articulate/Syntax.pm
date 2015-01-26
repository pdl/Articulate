package Articulate::Syntax;

use Scalar::Util qw(blessed);
use Module::Load ();

use Exporter::Declare;
default_exports qw(instantiate instantiate_array throw_error loc locspec dpath_get dpath_set);
use Articulate::Error;
use Data::DPath qw(dpath dpathr);

use Articulate::Item;
use Articulate::Error;
use Articulate::Location;
use Articulate::LocationSpecification;

sub throw_error { Articulate::Error::throw_error(@_) };
sub loc         { Articulate::Location::loc(@_) };

=head3 instantiate_array

C<instantiate_array> accepts an arrayref of values which represent objects. For each value, if it is not an object, it will attempt to instantiate one using C<instantiate>.

If you pass C<instantiate_array> a value which is not an arrayref, it will assume you meant to give it an arrayref with a single item; or, if you pass it C<undef>, it will return an empty arrayref.

The purpose of this function is to enable the following:

    package Articulate::SomeDelegatingComponent;
    use Moo;
    has delegates_to =>
      is      => 'rw',
      default => sub { [] },
      coerce  => sub{ instantiate_array(@_) };

Which means given config like the following:

    Articulate::SomeDelegatingComponent:
      delegates_to:
        - My::Validation::For::Articles
        - class: My::Validation::For::Images
          args:
            - max_width: 1024
              max_height: 768
        - class: My::Validation::For::Documents
          constructor: preset
          args: pdf

You can be guaranteed that looping through C<< @{ $self->delegates_to } >> will always produce objects.

=head3 instantiate

Attempts to create an object from the hashref or class name provided.

If the value is a string, it will treat as a class name, and perform C<< $class->new >>, or, if the method exists, C<< $class->instance >> will be preferred (for instance, as provided by C<MooX::Singleton>).

If the value is a hashref, it will look at the values for the keys C<class>, C<constructor>, and C<args>. It will then attempt to perform C<< $class->$constructor(@$args) >>, unless the constructor is absent (in which case C<instance> or C<new> will be supplied), or if C<args> is not an arrayref, in which case it will be passed to the constructor as a single argument (or the empty list will be passed if C<args> is undefined).

If the value is an object, the object will simply be returned.

=cut

sub instantiate {
  my $original = shift;
  if ( blessed $original ) {
    return $original;
  }
  elsif ( !ref $original ) {
    Module::Load::load($original);
    if ( $original->can('instance') ) {
      return $original->instance()
    }
    else {
      return $original->new();
    }
  }
  elsif ( ref $original eq ref {} ) {
    my $class = $original->{class};
    my $args  = $original->{args};
    if ( 1 == keys %$original and join ( '', keys %$original ) !~ /^[a-z_]/ ) { # single key that does not look like a class
      $class = join '', keys $original;
      $args  = $original->{$class};
    }
    throw_error Internal => 'Instantiation failed: expecting key class, got '.(join ', ', keys %$original) unless defined $class;
    Module::Load::load ( $class );
    my $constructor = $original->{constructor} // ($class->can('instance') ? 'instance' : 'new');
    my @args = (
      (defined $args)
      ? (ref $args eq ref [])
        ? @$args
        : $args
      : ()
    );
    return $class->$constructor(@args);
  }
}

sub instantiate_array {
  my $arrayref = shift;
  return [] unless defined $arrayref;
  # delegates_to => "Class::Name" should be interpreted as delegates_to => ["Class::Name"]
  $arrayref = [$arrayref] unless ref $arrayref and ref $arrayref eq ref [];
  return [ map { instantiate $_ } @$arrayref ];
}

=head3 from_meta

  sub email_address { from_meta (shift, 'schema/user/email_address'); }

This method uses Data::DPath to retrieve a field from the metadata structure.

=cut

sub from_meta {
  my $structure = shift;
  my $item      = shift;
  my @results   = dpath ($item->meta)->match($structure);
  return shift @results;
}

=head3 dpath_get

  my $value = dpath_get($structure, '/path/in/structure');

=cut

sub dpath_get {
  my $structure = shift;
  my $path      = shift;
  my @results   = dpath($path)->match($structure);
  return shift @results;
}

=head3 dpath_set

  dpath_set($structure, '/path/in/structure', $value);

=cut

sub dpath_set {
  my $structure = shift;
  my $path      = shift;
  my $value     = shift;
  my @results   = dpathr($path)->match($structure);
  map { $$_ = $value } @results;
  return $value if @results;
}

1;

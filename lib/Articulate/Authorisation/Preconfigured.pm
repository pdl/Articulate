package Articulate::Authorisation::Preconfigured;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';

has rules =>
  is      => 'rw',
  default => sub { {} };

sub permitted {
  my $self       = shift;
  my $permission = shift;
  my $user_id    = $permission->user;
  my $location   = $permission->location;
  my $verb       = $permission->verb;
  my $rules      = $self->rules;
  my $access     = undef;

  foreach my $rule_location (sort {length $a <=> length $b } keys $rules) {
    if ( $location =~ /^$rule_location\b/ ) {
      if ( grep { $_ eq $user_id } keys %{ $rules->{$rule_location} } ){
        if ( ref $rules->{$rule_location}->{$user_id} ) {
          if ( exists $rules->{$rule_location}->{$user_id}->{$verb} ) {
            my $value = !! $rules->{$rule_location}->{$user_id}->{$verb};
            return $permission->deny("User cannot $verb $rule_location") unless $value;
            $access = "User can $verb $rule_location";
          }
        }
        else {
          my $value = !! $rules->{$rule_location}->{$user_id};
          return $permission->deny("User cannot access $rule_location at all") unless $value                                                                                                                    ;
          $access = "User can access $rule_location";
        }
      }
    }
  }
  if (defined $access) {
    return $permission->grant($access);
  }

  return $permission;
}

1;

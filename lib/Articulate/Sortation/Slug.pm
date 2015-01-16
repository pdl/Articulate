package Articulate::Sortation::Slug;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

sub _left { -1 }

sub _right { 1 }

sub cmp {
  my $self  = shift;
  my $left  = shift;
  my $right = shift;
  my $re_break = qr/(?: # Breaks between groups of characters
  #  (?<=[a-z])|(?=[a-z]) # aa
    (?<=[a-z])(?![a-z]) # a0
  | (?<![a-z])(?=[a-z]) # 0a
  | (?<=[0-9])(?![0-9]) # 0_
  | (?<![0-9])(?=[0-9]) # _0
  )/ix;
  my $la = [ grep { $_ ne '' } split ($re_break, $left)];
  my $ra = [ grep { $_ ne '' } split ($re_break, $right)];
  #warn Dump {left => {$left, $la}, right => {$right,$ra}};
  while (scalar @$la && scalar  @$ra) {
    my $l = shift @$la;
    my $r = shift @$ra;
    if ($l =~ /^[^a-z0-9]/i) {
      if ($r =~ /^[a-z0-9]/i) {
        # left is dash and right is not - left wins
        return _left;
      }
      next; # otherwise both are dash - continue
    }
    elsif ($r =~ /^[^a-z0-9]/i) {
      # right is dash and left is not - right wins
      return _right;
    }
    elsif ($l =~ /^[0-9]/) {
      if ($r =~ /^[0-9]/) {
        # both are numbers
        my $res = ( $l <=> $r );
        return $res if $res;
      }
      else {
        # left is number, right is alpha -  left wins
        return _left;
      }
    }
    else {
      # both are alphabetic
      my $res = ( $l cmp $r );
      return $res if $res;
    }
  }
  return @$ra ? _left : 0 if (!@$la);
  return        _right    if (!@$ra);
  die 'shouldn\'t be here' if $left ne $right;
  return $left cmp $right;
}

1;

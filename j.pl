#
# j (2)
#
# Copyright (c) 2021 Henri Cattoire. Licensed under the WTFPL license.
#
use strict;
use warnings;

my $short_usage = "Usage: j REGEX ...\n";
my $help = <<'EOF';
Jump around.

    -m, --memorise          memorise the current directory.
    -f, --forget            forget the current directory.
    --help                  display this help and exit.

See man page for more information.
EOF

my $regex = "";
# environment variables
my $memory = glob($ENV{'_J_MEMORY'} // '~/.cache/j/j');
my $ignore = glob($ENV{'_J_IGNORE'} // 'NONE');

foreach (@ARGV) {
  # current element is stored in $_
  if (m/--help|-h/) {
    print $short_usage;
    print $help;
    exit 1;
  } elsif (m/--forget|-f/) {
    forget($ENV{'PWD'});
    exit 2;
  } elsif (m/--memorise|-m/) {
    memorise($ENV{'PWD'});
    exit 2;
  } else {
    $regex = $regex ne "" ? $regex . ".*\/.*$_" : $_;
  }
}

if (!$regex) {
  print $short_usage;
  exit 1;
}

{
  open my $fh, '<', $memory or die "Unable to access memory!\n";
  my @matches;
  while (<$fh>) {
    next unless m/$regex/i;
    my ($path, $frequency, $recency) = split ":", $_, 3;
    push @matches, { path => $path, frecency => $frequency / (time - $recency) };
  }
  close $fh;
  @matches = sort { length $a->{path} <=> length $b->{path} } @matches;
  if (not common(\@matches)) {
    @matches = sort { $b->{frecency} <=> $a->{frecency} } @matches;
  }
  print $matches[0]->{path} || die "Nothing in memory matched.\n";
}

sub common {
  my ($begin, $i) = (@{$_[0]}[0], 0);
  foreach my $val (@{$_[0]}) {
    last unless $val->{path} =~ m/^$begin->{path}/;
    $i += 1;
  }
  $i == scalar @{$_[0]};
}

sub forget {
  my ($path) = @_;
  local $^I = "";
  local @ARGV = $memory;
  while (<>) {
    next if m/^$path:/;
    print;
  }
}

sub memorise {
  my ($path, $updated) = (@_, 0);
  # do not clutter memory with $HOME and avoid ignored directories
  return if $path eq $ENV{'HOME'} || ($ignore ne "NONE" && $path =~ m/$ignore/);

  local $^I = "";
  local @ARGV = $memory;
  while (<>) {
    s/^($path:)(\d+):\d+$/$updated = 1; $1 . ($2 + 1) . ":" . time()/e;
    print;
  }
  # add new entry
  if (!$updated) {
    open my $fh, '>>', $memory or die "Unable to access memory!\n";
    print $fh ($path . ":1:" . time . "\n");
    close $fh;
  }
}

# This script uses the value stored in ~/.config/conforg/colorscheme
# to update color configurations in kitty.conf.

$file      = $ENV{"HOME"} . "/.config/kitty/kitty.conf";
$darkfile  = $ENV{"HOME"} . "/.config/kitty/solarized-dark.conf";
$lightfile = $ENV{"HOME"} . "/.config/kitty/solarized-light.conf";

$switchfile = $ENV{"HOME"} . "/.config/conforg/colorscheme";

open my $in,  '<',  $file      or die "Can't read old file $file: $!";

open my $dark,  "<", $darkfile   or die "Can't open $darkfile: $!";
open my $light, "<", $lightfile  or die "Can't open $lightfile: $!";

open my $color, "<", $switchfile or die "Can't open $switchfile: $!";
my $newcolor = <$color>;

my $dark_first_line  = <$dark>;
my $light_first_line = <$light>;

# exit if the current colorscheme is up to date
my $in_first_line = <$in>;
if ( $in_first_line eq "# Current color scheme: $newcolor" )
{
  print "No changes necessary to $file.";
  exit 0;
}
else
{
  open my $out, '>', "$file.new" or die "Can't write new file $file.new: $!";
  print $out "# Current color scheme: $newcolor";
}

open my $out, '>>', "$file.new" or die "Can't write new file $file.new: $!";

while( <$in> )
{
  # copy over until hit the first line of color config
  last if $_ eq $dark_first_line;
  last if $_ eq $light_first_line;
  print $out $_;
}

if ( $newcolor eq "dark\n" )
{
  print $out $dark_first_line;
  while ( <$dark> )
  {
    print $out $_;
    $current_line = <$in>;
  }
}
else
{
  if ( $newcolor eq "light\n" )
  {
    print $out $light_first_line;
    while ( <$light> )
    {
      print $out $_;
      $current_line = <$in>;
    }
  }
  else
  {
    die "Can't handle the color option in $switchfile: $newcolor";
  }
}

while( <$in> )
{
  # copy over whatever is left
  print $out $_;
}

close $out;
close $in;

use File::Copy qw(move);
move "$file.new", $file;

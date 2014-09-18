#!/usr/bin/perl
use Cwd;
use POSIX qw/strftime/;
use Getopt::Long;
use File::Basename;

my @regex =( # Remove <div>
             { pattern => qr|<[/]?div[^>]*>|,
               subst   => "" },
             # Remove links
             { pattern => qr|<[/]?a[^>]*>|,
               subst   => "" },
             # Remove <b>
             { pattern => qr|<[/]?b[\W]*>|,
               subst   => "" },
             # Remove <pre>
             { pattern => qr|<[/]?pre[\W]*>|,
               subst   => "" },
             # Make headers comments
             { pattern => qr|<\W*h[0-9][\W]*>([^<]*)<\W*/h[0-9]\W*>|,
               subst   => q("// $1") },
             # Make font color=red literal strings
             { pattern => qr|<\W*font\W+color="red"\W*>([^<]*)<\W*/font\W*>|,
               subst   => q("'$1'") },
#             # Replace {}
#             { pattern => qr|([^']?)\{([^']?[^}]+[^']?)\}([^']?)|,
#               subst   => q("$1( $2 )*$3") },
#             # Replace []
#             { pattern => qr|([^']?)\[([^']?[^\]]+[^']?)\]([^']?)|,
#               subst   => q("$1( $2 )?$3") },
             # Replace {
             { pattern => qr|([^'])\{([^'])|,
               subst   => q("$1\($2") },
             # Replace }
             { pattern => qr|([^'])\}([^'])|,
               subst   => q("$1\)*$2") },
             # Replace [
             { pattern => qr|([^'])\[([^'])|,
               subst   => q("$1\($2") },
             # Replace ]
             { pattern => qr|([^'])\]([^'])|,
               subst   => q("$1\)?$2") },
             # Remove ::=
             { pattern => qr|::=|,
               subst   => q(":") },
             # Replace &lt;
             { pattern => qr|&lt;|,
               subst   => q("<") },
             # Replace &gt;
             { pattern => qr|&gt;|,
               subst   => q(">") },
             # Replace &amp;
             { pattern => qr|&amp;|,
               subst   => q("&") }
    );
# Get options
# ------------------------------------------------------------------------------
GetOptions('src=s'   => \$src_file,
           'dest=s'  => \$dest_file,
           'h'       => \$help);

if ($help) {
    print "Usage:\n";
    print "  --project <project file name>\n";
    exit;
}

my $bnf = "";


open SRCFILE, "<", $src_file or die $!;
local $/ = undef;
my $src = <SRCFILE>;
close SRCFILE;

print "Parsing file $src_file...\n";
foreach $p (@regex) {
    my $match;
    #print "   pattern $p->{pattern} : $p->{subst}\n";
    if ($src =~ s|$p->{pattern}|$p->{subst}|gee) {
        print "   Found $p->{pattern} in $src_file\n";
#        if (exists $info{$file}) {
#            push(@{$info{$file}}, $component);
#        } else {
#            $info{$file} = ();
#            push(@{$info{$file}}, $component);
#        }

    } else {
        print "   $p->{pattern} not found\n";
    }
#        print "   with pattern $p\n";
}

# Put semicolons after every block of text, but then remove them from comment blocks.
$src =~ s|(.*)\n\s*\n|\1;\n\n|g;
$src =~ s|\n[ ]*//(.*?);[ ]*\n|\n//\1\n|g;


open DESTFILE, ">", $dest_file or die $!;
print DESTFILE "grammar SystemVerilog1800;";
print DESTFILE $src;
close DESTFILE;

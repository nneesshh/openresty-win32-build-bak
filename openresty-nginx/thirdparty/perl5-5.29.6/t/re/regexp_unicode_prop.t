#!./perl
#
# Tests that have to do with checking whether characters have (or not have)
# certain Unicode properties; belong (or not belong) to blocks, scripts, etc.
#

use strict;
use warnings;
use 5.010;

my @warnings;
local $SIG {__WARN__} = sub {push @warnings, "@_"};

BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    skip_all_if_miniperl("no dynamic loading on miniperl, no File::Spec (used by charnames)");
}

sub run_tests;

sub get_str_name($) {
    my $char = shift;

    my ($str, $name);

    if ($char =~ /^\\/) {
        $str  = eval qq ["$char"];
        $name =      qq ["$char"];
    }
    elsif ($char =~ /^0x([0-9A-Fa-f]+)$/) {
        $str  =  chr hex $1;
        $name = "chr ($char)";
    }
    else {
        $str  =      $char;
        $name = qq ["$char"];
    }

    return ($str, $name);
}

#
# This is the data to test.
#
# This is a hash; keys are the property to test.
# Values are arrays containing characters to test. The characters can
# have the following formats:
#   '\N{CHARACTER NAME}'  -  Use character with that name
#   '\x{1234}'            -  Use character with that hex escape
#   '0x1234'              -  Use chr() to get that character
#   "a"                   -  Character to use
#
# If a character entry starts with ! the character does not belong to the class
#
# If the class is just single letter, we use both \pL and \p{L}
#

use charnames ':full';

my @CLASSES = (
    L                         => ["a", "A"],
    Ll                        => ["b", "!B"],
    Lu                        => ["!c", "C"],
    IsLl                      => ["d", "!D"],
    IsLu                      => ["!e", "E"],
    LC                        => ["f", "!1"],
   'L&'                       => ["g", "!2"],
   'Lowercase Letter'         => ["h", "!H"],

    Common                    => ["!i", "3"],
    Inherited                 => ["!j", '\x{300}'],

    InBasicLatin              => ['\N{LATIN CAPITAL LETTER A}'],
    InLatin1Supplement        => ['\N{LATIN CAPITAL LETTER A WITH GRAVE}'],
    InLatinExtendedA          => ['\N{LATIN CAPITAL LETTER A WITH MACRON}'],
    InLatinExtendedB          => ['\N{LATIN SMALL LETTER B WITH STROKE}'],
    InKatakana                => ['\N{KATAKANA LETTER SMALL A}'],
    IsLatin                   => ["0x100", "0x212b"],
    IsHebrew                  => ["0x5d0", "0xfb4f"],
    IsGreek                   => ["0x37a", "0x386", "!0x387", "0x388",
                                  "0x38a", "!0x38b", "0x38c"],
    HangulSyllables           => ['\x{AC00}'],
   'Script=Latin'             => ['\x{0100}'],
   'Block=LatinExtendedA'     => ['\x{0100}'],
   'Category=UppercaseLetter' => ['\x{0100}'],

    #
    # It's ok to repeat class names.
    #
    InLatin1Supplement        =>
                            ['!\N{U+7f}',  '\N{U+80}',  '\N{U+ff}', '!\x{100}'],
    InLatinExtendedA          =>
                            ['!\N{U+7f}', '!\N{U+80}', '!\N{U+ff}',  '\x{100}'],

    #
    # Properties are case-insensitive, and may have whitespace,
    # dashes and underscores.
    #
   'in-latin1_SUPPLEMENT'     => ['\N{U+80}',
                                  '\N{LATIN SMALL LETTER Y WITH DIAERESIS}'],
   '  ^  In Latin 1 Supplement  '
                              => ['!\N{U+80}', '\N{COFFIN}'],
   'latin-1   supplement'     => ['\N{U+80}', "0xDF"],

);

my @USER_DEFINED_PROPERTIES;
my @USER_CASELESS_PROPERTIES;
my @DEFERRED;
BEGIN {

    # We defined these at compile time, so that the subroutines that they
    # refer to aren't known, so that we can test properties not known until
    # runtime

    @USER_DEFINED_PROPERTIES = (
        #
        # User defined properties
        #
        InKana1                   => ['\x{3040}', '!\x{303F}'],
        InKana2                   => ['\x{3040}', '!\x{303F}'],
        InKana3                   => ['\x{3041}', '!\x{3040}'],
        InNotKana                 => ['\x{3040}', '!\x{3041}'],
        InConsonant               => ['d',        '!e'],
        IsSyriac1                 => ['\x{0712}', '!\x{072F}'],
        IsSyriac1KanaMark         => ['\x{309A}', '!\x{3090}'],
        IsSyriac1KanaMark         => ['\x{0730}', '!\x{0712}'],
        '# User-defined character properties may lack \n at the end',
        InGreekSmall              => ['\N{GREEK SMALL LETTER PI}',
                                        '\N{GREEK SMALL LETTER FINAL SIGMA}'],
        InGreekCapital            => ['\N{GREEK CAPITAL LETTER PI}', '!\x{03A2}'],
        Dash                      => ['-'],
        ASCII_Hex_Digit           => ['!-', 'A'],
        IsAsciiHexAndDash         => ['-', 'A'],
    );

    @USER_CASELESS_PROPERTIES = (
        #
        # User defined properties which differ depending on /i.  Second entry
        # is false normally, true under /i
        #
        'IsMyUpper'                => ["M", "!m" ],
        'pkg::IsMyLower'           => ["a", "!A" ],
    );


    # Now create a list of properties whose definitions won't be known at
    # runtime.  The qr// below thus will have forward references to them, and
    # when matched at runtime will not know what's in the property definition
    my @DEFERRABLE_USER_DEFINED_PROPERTIES;
    push @DEFERRABLE_USER_DEFINED_PROPERTIES, @USER_DEFINED_PROPERTIES;
    push @DEFERRABLE_USER_DEFINED_PROPERTIES, @USER_CASELESS_PROPERTIES;
    for (my $i = 0; $i < @DEFERRABLE_USER_DEFINED_PROPERTIES; $i+=2) {
        my $property = $DEFERRABLE_USER_DEFINED_PROPERTIES[$i];
        if ($property =~ / ^ \# /x) {
            $i++;
            redo;
        }

        # Only do this for the properties in the list that are user-defined
        next if ($property !~ / ( ^ | :: ) I[ns] /x);

        push @DEFERRED, qr/\p{$property}/,
                        $DEFERRABLE_USER_DEFINED_PROPERTIES[$i+1];
    }
}

# These override the official ones, so if found before defined, the official
# ones prevail, so can't test deferred definition
my @OVERRIDING_USER_DEFINED_PROPERTIES = (
   InLatin1                  => ['\x{0100}', '!\x{00FF}'],
);

#
# From the short properties we populate POSIX-like classes.
#
my %SHORT_PROPERTIES = (
    'Ll'  => ['m', '\N{CYRILLIC SMALL LETTER A}'],
    'Lu'  => ['M', '\N{GREEK CAPITAL LETTER ALPHA}'],
    'Lo'  => ['\N{HIRAGANA LETTER SMALL A}'],
    # is also in other alphabetic
    'Mn'  => ['\N{HEBREW POINT RAFE}'],
    'Nd'  => ["0", '\N{ARABIC-INDIC DIGIT ZERO}'],
    'Pc'  => ["_"],
    'Po'  => ["!"],
    'Zs'  => [" "],
    'Cc'  => ['\x{00}'],
);

#
# Illegal properties
#
my @ILLEGAL_PROPERTIES =
    qw[q qrst f foo isfoo infoo ISfoo INfoo Is::foo In::foo];

my %d;

while (my ($class, $chars) = each %SHORT_PROPERTIES) {
    push @{$d {IsAlpha}} => map {$class =~ /^[LM]/   ? $_ : "!$_"} @$chars;
    push @{$d {IsAlnum}} => map {$class =~ /^[LMN]./ ? $_ : "!$_"} @$chars;
    push @{$d {IsASCII}} => map {length ($_) == 1 || $_ eq '\x{00}'
                                                     ? $_ : "!$_"} @$chars;
    push @{$d {IsCntrl}} => map {$class =~ /^C/      ? $_ : "!$_"} @$chars;
    push @{$d {IsBlank}} => map {$class =~ /^Z[lps]/ ? $_ : "!$_"} @$chars;
    push @{$d {IsDigit}} => map {$class =~ /^Nd$/    ? $_ : "!$_"} @$chars;
    push @{$d {IsGraph}} => map {$class =~ /^([LMNPS]|Co)/
                                                     ? $_ : "!$_"} @$chars;
    push @{$d {IsPrint}} => map {$class =~ /^([LMNPS]|Co|Zs)/
                                                     ? $_ : "!$_"} @$chars;
    push @{$d {IsLower}} => map {$class =~ /^Ll$/    ? $_ : "!$_"} @$chars;
    push @{$d {IsUpper}} => map {$class =~ /^L[ut]/  ? $_ : "!$_"} @$chars;
    push @{$d {IsPunct}} => map {$class =~ /^P/      ? $_ : "!$_"} @$chars;
    push @{$d {IsWord}}  => map {$class =~ /^[LMN]/ || $_ eq "_"
                                                     ? $_ : "!$_"} @$chars;
    push @{$d {IsSpace}} => map {$class =~ /^Z/ ||
                                 length ($_) == 1 && utf8::native_to_unicode(ord ($_)) >= 0x09
                                                  && utf8::native_to_unicode(ord ($_)) <= 0x0D
                                                     ? $_ : "!$_"} @$chars;
}

push @CLASSES => "# Short properties"        => %SHORT_PROPERTIES,
                 "# POSIX like properties"   => %d,
                 "# User defined properties" => @USER_DEFINED_PROPERTIES,
                 "# Overriding user defined properties" => @OVERRIDING_USER_DEFINED_PROPERTIES;


#
# Calculate the number of tests.
#
my $count = 0;
for (my $i = 0; $i < @CLASSES; $i += 2) {
    $i ++, redo if $CLASSES [$i] =~ /^\h*#\h*(.*)/;
    $count += 2 * (length $CLASSES [$i] == 1 ? 4 : 2) * @{$CLASSES [$i + 1]};
}
$count += 4 * @ILLEGAL_PROPERTIES;
$count += 4 * grep {length $_ == 1} @ILLEGAL_PROPERTIES;
$count += 8 * @USER_CASELESS_PROPERTIES;
$count += 1 * @DEFERRED / 2;
$count += 1;    # No warnings generated

plan(tests => $count);

run_tests unless caller ();

sub match {
    my ($char, $match, $nomatch, $caseless) = @_;
    $caseless = "" unless defined $caseless;
    $caseless = 'i' if $caseless;

    my ($str, $name) = get_str_name($char);

    undef $@;
    my $pat = "qr/$match/$caseless";
    my $match_pat = eval $pat;
    if (is($@, '', "$pat compiled correctly to a regexp: $@")) {
        like($str, $match_pat, "$name correctly matched");
    }

    undef $@;
    $pat = "qr/$nomatch/$caseless";
    my $nomatch_pat = eval $pat;
    if (is($@, '', "$pat compiled correctly to a regexp: $@")) {
        unlike($str, $nomatch_pat, "$name correctly did not match");
    }
}

sub run_tests {

    for (my $i = 0; $i < @DEFERRED; $i+=2) {
            my ($str, $name) = get_str_name($DEFERRED[$i+1][0]);
            like($str, $DEFERRED[$i],
                "$name correctly matched $DEFERRED[$i] (defn. not known until runtime)");
    }

    while (@CLASSES) {
        my $class = shift @CLASSES;
        if ($class =~ /^\h*#\h*(.*)/) {
            print "# $1\n";
            next;
        }
        last unless @CLASSES;
        my $chars   = shift @CLASSES;
        my @in      =                       grep {!/^!./} @$chars;
        my @out     = map {s/^!(?=.)//; $_} grep { /^!./} @$chars;
        my $in_pat  = eval qq ['\\p{$class}'];
        my $out_pat = eval qq ['\\P{$class}'];

        match $_, $in_pat,  $out_pat for @in;
        match $_, $out_pat, $in_pat  for @out;

        if (1 == length $class) {   # Repeat without braces if name length 1
            my $in_pat  = eval qq ['\\p$class'];
            my $out_pat = eval qq ['\\P$class'];

            match $_, $in_pat,  $out_pat for @in;
            match $_, $out_pat, $in_pat  for @out;
        }
    }


    print "# Illegal properties\n";
    foreach my $p (@ILLEGAL_PROPERTIES) {
        my $pat;
        if ($p =~ /::/) {
            $pat = qr /^Illegal user-defined property name/;
        }
        else {
            $pat = qr /^Can't find Unicode property definition/;
        }

        undef $@;
        my $r = eval "'a' =~ /\\p{$p}/; 1";
        is($r, undef, "Unknown Unicode property \\p{$p}");
        like($@, $pat, "Unknown Unicode property \\p{$p}");
        undef $@;
        my $s = eval "'a' =~ /\\P{$p}/; 1";
        is($s, undef, "Unknown Unicode property \\p{$p}");
        like($@, $pat, "Unknown Unicode property \\p{$p}");
        if (length $p == 1) {
            undef $@;
            my $r = eval "'a' =~ /\\p$p/; 1";
            is($r, undef, "Unknown Unicode property \\p$p");
            like($@, $pat, "Unknown Unicode property \\p$p");
            undef $@;
            my $s = eval "'a' =~ /\\P$p/; 1";
            is($r, undef, "Unknown Unicode property \\P$p");
            like($@, $pat, "Unknown Unicode property \\P$p");
        }
    }

    print "# User-defined properties with /i differences\n";
    while (my $class = shift @USER_CASELESS_PROPERTIES) {
        my $chars_ref = shift @USER_CASELESS_PROPERTIES;
        my @in      =                       grep {!/^!./} @$chars_ref;
        my @out     = map {s/^!(?=.)//; $_} grep { /^!./} @$chars_ref;
        my $in_pat  = eval qq ['\\p{$class}'];
        my $out_pat = eval qq ['\\P{$class}'];

        # Verify that adding /i does change the out set to match.
        match $_, $in_pat,  $out_pat, 'i' for @out;

        # Verify that adding /i doesn't change the in set.
        match $_, $in_pat,  $out_pat, 'i' for @in;

        # Verify works as regularly for not /i
        match $_, $in_pat,  $out_pat for @in;
        match $_, $out_pat, $in_pat  for @out;


    }
}


#
# User defined properties
#

sub InKana1 {<<'--'}
3040    309F
30A0    30FF
--

sub InKana2 {<<'--'}
+utf8::InHiragana
+utf8::InKatakana
--

sub InKana3 {<<'--'}
+utf8::InHiragana
+utf8::InKatakana
-utf8::IsCn
--

sub InNotKana {<<'--'}
!utf8::InHiragana
-utf8::InKatakana
+utf8::IsCn
--

sub InConsonant {

    my $return = "+utf8::Lowercase\n&utf8::ASCII\n";
    $return .= sprintf("-%X\n", ord "a");
    $return .= sprintf("-%X\n", ord "e");
    $return .= sprintf("-%X\n", ord "i");
    $return .= sprintf("-%X\n", ord "o");
    $return .= sprintf("-%X\n", ord "u");
    return $return;
}

sub IsSyriac1 {<<'--'}
0712    072C
0730    074A
--

sub InGreekSmall   {return "03B1\t03C9"}
sub InGreekCapital {return "0391\t03A9\n-03A2"}

sub IsAsciiHexAndDash {<<'--'}
+utf8::ASCII_Hex_Digit
+utf8::Dash
--

sub InLatin1 {
    return "0100\t10FFFF";
}

sub IsMyUpper {
    my $caseless = shift;
    return "+utf8::"
           . (($caseless)
               ? 'Alphabetic'
               : 'Uppercase')
           . "\n&utf8::ASCII";
}

sub pkg::IsMyLower {
    my $caseless = shift;
    return "+utf8::"
        . (($caseless)
            ? 'Alphabetic'
            : 'Lowercase')
        . "\n&utf8::ASCII";
}

# Verify that can use user-defined properties inside another one
sub IsSyriac1KanaMark {<<'--'}
+main::IsSyriac1
+main::InKana3
&utf8::IsMark
--

# fake user-defined properties; these subs shouldn't be called, because
# their names don't start with In or Is

sub f       { die }
sub foo     { die }
sub isfoo   { die }
sub infoo   { die }
sub ISfoo   { die }
sub INfoo   { die }
sub Is::foo { die }
sub In::foo { die }

if (! is(@warnings, 0, "No warnings were generated")) {
    diag join "\n", @warnings, "\n";
}

1;
__END__

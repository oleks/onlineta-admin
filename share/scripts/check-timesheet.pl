#!/usr/bin/env perl

$expass = $ARGV[0] or die "usage: $0 <ass#>\n";

open T, "<timesheet.txt" || die "  File `timesheet.txt` missing";

$ass = "<unknown>";
while (<T>) {
    if (/^\s*#/) {
    }
    elsif (/^Assignment:\s*(\d+)\s*(#.*)?/) {
        $ass = $1;
    } elsif (/^([a-zA-Z\-]+):\s*(((\d+)\s*(?:h|hr|hrs|hour|hours)|)\s*((\d+)\s*(?:m|min|minute|minutes)|)|(x))\s*(#.*)?$/) {
#        print "cat: |$1|, hrs: |$4|, min: |$6|, x: |$7|\n";
        if ($4 eq "" && $6 eq "" && $7 eq "") {
            die "  Error: blank time estimate for category `$1`\n";
        } else {
            $m = $4 * 60 + $6;
            if ($7 eq "x") {$m = -1;}
#            print "Cat $1: $m minutes\n"
        }
    } else {
        die "  Error: cannot parse line: $_\n";
    }
}

if ($ass eq $expass) {
    print "  Timesheet looks OK\n";
} else {
    die "  Error: timesheet is for Assignment $ass, should be $expass\n"
}


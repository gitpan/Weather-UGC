# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Weather::UGC;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $count = $loaded+1;

$count = test_ugc($count, 1, 'NYZ009-015>018-022>025-036-037-044>046-055>057-062-PAZ038>040-043-044-047-048-310900-');
$count = test_ugc($count, 1, 'NYZ078>081-NJZ002>004-011-141200-');
$count = test_ugc($count, 1, 'FLZ004-310900-');
$count = test_ugc($count, 0, 'PDQ004-310900-');
$count = test_ugc($count, 0, 'CTZ001-');


sub test_ugc {
    my ($i_test, $desired, $str_ugc) = @_;
    my $result;

    unless ($i_test) {
        return 0;
    }

    $result = (Weather::UGC::valid $str_ugc);

    if ($result)
    {
        my $UGC = new Weather::UGC($str_ugc);
        my $count_invalid = 0;

        foreach ($UGC->zones) {
            unless (Weather::UGC::valid ZONE, $_) { $count_invalid++; }
        }
        $result = ($result == ($count_invalid == 0));
    }

    if ($result==$desired)
    {
        print "ok $i_test\n";
        return (++$i_test);
    } else {
        print "not ok $i_test\n";
        return 0;
    }
}




# foreach (sort $ugc->zones) { print $_, "\n"; }
use strict;
use warnings;
use Test::More;
use Try::Catch;

#############################################################
# this test pass javascript but not this module since we don't
# throw an error if there is no catch block, I'll keep it here 
# in order to see if it's a better approach to throw by default
##############################################################
# {
#   try {
#       try {
#           die "inner oops";
#       }
#       finally {
#           pass("finally called");
#       };
#   }
#   catch {
#       ok ($_ =~ /^inner oops/);
#   };
# }


{
    try {
        try {
            die "inner oops";
        }
        catch {
            ok ($_ =~ /^inner oops/);
        }
        finally {
            pass("finally called");
        };
    }
    catch {
        fail("should not be called");
    };
}

{
    try {
        try {
            die "inner2 oops";
        }
        catch {
            ok($_ =~ /^inner2 oops/);
            die $_;
        }
        finally {
            pass("finally called");
        };
    }
    catch {
        ok($_ =~ /^inner2 oops/);
    };
}

{
    my $val = 0;
    my @expected;
    try {
        try {
            try {
                try {
                    die "9";
                } catch {
                    $val = 9;
                    die $_;
                } finally {
                    try {
                        push @expected, 1;
                        is($val, 9, "first finally called");
                        die "new Error";
                    } catch {};
                };
            } catch {
                pass("cach called");
                push @expected, 2;
            } finally {
                die "second finally called $val\n";
            };
            fail("should not reach here");
        }  catch {
            $val = 10;
            die $_;
        } finally {
            push @expected, 3;
            is ($val, 10, "final finally called");
        };
        fail("should not reach here");
    } catch {
        ok ($_ =~ /^second finally called 9/);
    };
    is_deeply \@expected, [1,2,3];
}

done_testing(10);
1;

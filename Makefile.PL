use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Try::Catch',
    VERSION_FROM      => 'lib/Try/Catch.pm', # finds $VERSION
    PREREQ_PM         => {}, # none
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Try/Catch.pm', # retrieve abstract from module
       AUTHOR         => 'Mamod A. Mehyar <mamod.mehyar@gmail.com>') : ())
);
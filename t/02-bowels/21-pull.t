#!perl

use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Pinto::Tester;
use Pinto::Tester::Util qw(make_dist_archive);

#------------------------------------------------------------------------------

my $source = Pinto::Tester->new;
$source->populate('JOHN/Baz-1.2 = Baz~1.2 & Nuts-2.3');
$source->populate('PAUL/Nuts-2.3 = Nuts~2.3');

#------------------------------------------------------------------------------
subtest 'non-recursive pull' => sub {

    # Non-recursive pull
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    $local->run_ok( 'Pull', { targets => 'Baz~1.2', recurse => 0 } );
    $local->registration_ok('JOHN/Baz-1.2/Baz~1.2');
    $local->registration_not_ok('PAUL/Nuts-2.3/Nuts~2.3');

};

#------------------------------------------------------------------------------
subtest 'recursive pull by package' => sub {

    # Recursive pull by package
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    my $result = $local->run_ok( 'Pull', { targets => 'Baz~1.2' } );
    $local->result_changed_ok($result);

    $local->registration_ok('JOHN/Baz-1.2/Baz~1.2');
    $local->registration_ok('PAUL/Nuts-2.3/Nuts~2.3');

    # Re-pulling
    $result = $local->run_ok( 'Pull', { targets => 'Baz~1.2' } );
    $local->result_not_changed_ok($result);

};

#------------------------------------------------------------------------------
subtest 'recursive pull by distribution' => sub {

    # Recursive pull by distribution
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    my $result = $local->run_ok( 'Pull', { targets => 'JOHN/Baz-1.2.tar.gz' } );
    $local->result_changed_ok($result);
    $local->registration_ok('JOHN/Baz-1.2/Baz~1.2');
    $local->registration_ok('PAUL/Nuts-2.3/Nuts~2.3');

    # Re-pulling
    $result = $local->run_ok( 'Pull', { targets => 'JOHN/Baz-1.2.tar.gz' } );
    $local->result_not_changed_ok($result);

};

#------------------------------------------------------------------------------
subtest 'pull non-existant package' => sub {

    # Pull non-existant package
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    $local->run_throws_ok( 'Pull', { targets => 'Nowhere~1.2' }, qr/Cannot find Nowhere~1.2 anywhere/ );

};

#------------------------------------------------------------------------------
subtest 'pull non-existant distribution' => sub {

    # Pull non-existant dist
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    $local->run_throws_ok(
        'Pull',
        { targets => 'JOHN/Nowhere-1.2.tar.gz' },
        qr{Cannot find JOHN/Nowhere-1.2.tar.gz anywhere}
    );

};

#------------------------------------------------------------------------------
subtest 'pull core-only module' => sub {

    # Pull a core-only module (should be ignored)
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    $local->run_ok( Pull => { targets => 'IPC::Open3' } );
    $local->stderr_like(qr/Skipping IPC::Open3~0: included in perl/);
    $local->repository_clean_ok;

};

#------------------------------------------------------------------------------
subtest 'pull new distribution with overlapping packages' => sub {

    # When pulling a new dist, any overlapping packages from an existing 
    # distribution with the same packages should be removed.  In this case 
    # it is PkgA and PkgC

    my $t = Pinto::Tester->new;

    $t->populate('AUTHOR/Dist-1 = PkgA~1; PkgB~1');
    $t->populate('AUTHOR/Dist-2 = PkgC~1');
    $t->registration_ok('AUTHOR/Dist-1/PkgA~1');
    $t->registration_ok('AUTHOR/Dist-1/PkgB~1');
    $t->registration_ok('AUTHOR/Dist-2/PkgC~1');

    $t->populate('AUTHOR/Dist-3 = PkgB~3; PkgC~3');
    $t->registration_not_ok('AUTHOR/Dist-1/PkgA~1');
    $t->registration_not_ok('AUTHOR/Dist-1/PkgB~1');
    $t->registration_not_ok('AUTHOR/Dist-2/PkgC~2');
    $t->registration_ok('AUTHOR/Dist-3/PkgB~3');
    $t->registration_ok('AUTHOR/Dist-3/PkgC~3');

};

#------------------------------------------------------------------------------

subtest 'Allow dry run pull on locked repo' => sub {

    # Non-recursive pull
    my $local = Pinto::Tester->new( init_args => { sources => $source->stack_url } );
    $local->run_ok( 'Lock' => {} );
    $local->stack_is_locked_ok('master');
    $local->run_ok( 'Pull', { dry_run => 1, targets => 'Baz~1.2', recurse => 0 } );
    $local->repository_clean_ok;

};

done_testing;

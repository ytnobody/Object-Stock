use Test::More;
use strict;

use Object::Stock;
use Object::Stock::Test qw/ build_obj show_pattern /;

sub build_stock {
    return Object::Stock->new( 
        builder     => sub { bless {@_}, 'MyClass' },
        max_objects => 3,
        expire      => 3,
    );
}

subtest expire => sub {
    my $stock = build_stock();

    my %args = ( name => 'hoge', age => '77' );
    build_obj( $stock, %args );

    my @expect = ( 1, 1, 1, 1, 0 );
    for my $i ( 0 .. 4 ) {
        if ( $expect[$i] ) {
            ok $stock->is_stored( %args ), $i.' sec expired. expect stored, but looks purged';
        }
        else {
            ok ! $stock->is_stored( %args ), $i.' sec expired. expect purged, but looks expired';
        }
        sleep 1;
    }
};

done_testing;

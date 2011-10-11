use Test::More;
use strict;

use Object::Stock;
use Object::Stock::Test qw/ build_obj show_pattern /;

sub build_stock {
    return Object::Stock->new( 
        builder     => sub { bless {@_}, 'MyClass' },
        max_objects => 3,
    );
}

subtest multiple_get => sub {
    my $stock = build_stock();

    my @records = (
        { name => 'hogehoge', age => 20 },
        { name => 'piyopiyo', age => 30 },
        { name => 'munimoni', age => 10 },
        { name => 'hagehage', age => 40 },
    );

    my @patterns = (
        [ $records[0], 1 ],
        [ $records[1], 2 ],
        [ $records[0], 2 ],
        [ $records[2], 3 ],
        [ $records[3], 3 ],
    );

    for my $p ( @patterns ) {
        my ( $args, $count ) = @$p;
        build_obj( $stock, %$args );
        is scalar keys %{$stock->objects}, $count, 'count_test'.show_pattern( $p );
    }

    my @stored = ( 1, 1, 1, 0 );
    for my $i ( 0 .. $#records ) {
        if ( $stored[$i] ) {
            ok $stock->is_stored( %{$records[$i]} );
        }
        else {
            ok ! $stock->is_stored( %{$records[$i]} );
        }
    }
};

done_testing;

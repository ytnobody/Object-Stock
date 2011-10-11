use Test::More;
use strict;

use Object::Stock;
use Object::Stock::Test qw/ build_obj show_pattern /;

sub build_stock {
    return Object::Stock->new( 
        builder     => sub { bless {@_}, 'MyClass' },
        identifier  => sub { my $args = { @_ }; return $args->{name} },
        max_objects => 10,
    );
}

subtest multiple_objects_with_single_identifier => sub {
    my $stock = build_stock();

    my @records = (
        { name => 'hogehoge', age => 20 },
        { name => 'munimoni', age => 30 },
        { name => 'piyopiyo', age => 30 },
        { name => 'munimoni', age => 10 },
        { name => 'hagehage', age => 40 },
        { name => 'hagehage', age => 20 },
    );

    my @patterns = (
        [ $records[0], 1 ],
        [ $records[1], 2 ],
        [ $records[0], 2 ],
        [ $records[2], 3 ],
        [ $records[3], 3 ],
        [ $records[4], 4 ],
        [ $records[5], 4 ],
    );

    my @is_equal = ( 1, 1, 1, 1, 0, 1, 0 );
    for my $i ( 0 .. $#patterns ) {
        my $p = $patterns[$i];
        my ( $args, $count ) = @$p;
        if ( $is_equal[$i] ) {
            build_obj( $stock, %$args );
        }
        else {
            fail_obj( $stock, %$args );
        }
        is scalar keys %{$stock->objects}, $count, 'count_test'.show_pattern( { $i => $p } );
    }

    for my $i ( 0 .. $#records ) {
        ok $stock->is_stored( %{$records[$i]} ), 'is stored'. show_pattern( { $i => $records[$i] } );
    }
};

done_testing;

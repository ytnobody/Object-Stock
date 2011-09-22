use Test::More;
use strict;

use Object::Stock;
use Object::Stock::Test qw/ build_obj /;

sub build_stock {
    return Object::Stock->new( builder => sub { bless {@_}, 'MyClass' } );
}

subtest basic => sub {
    my $stock = build_stock();
    is $stock->expire, 0;
    is $stock->max_objects, 1;
};

subtest get => sub {
    my $stock = build_stock();

    is scalar keys %{$stock->objects}, 0;
    my $obj = build_obj( $stock, name => 'oreore', age => 30 );
    is scalar keys %{$stock->objects}, 1;
};

subtest multipul_get => sub {
    my $stock = build_stock();

    my $obj = build_obj( $stock, name => 'hogehoge', age => 20 );
    is scalar keys %{$stock->objects}, 1;
    $obj = build_obj( $stock, name => 'poopoo', age => 40 );
    is scalar keys %{$stock->objects}, 1;
};

done_testing;

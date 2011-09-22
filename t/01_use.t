use Test::More;
use strict;

use Object::Stock;

my $stock = Object::Stock->new(
    builder => sub { bless 'MyClass', {@_} }
);

isa_ok $stock, 'Object::Stock';

done_testing;

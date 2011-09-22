use Test::More;
use strict;

use Object::Stock;

my $stock = Object::Stock->new( 
    builder => sub { 
        my %args = @_;
        return bless 'MyClass', {%args};
    }
);

can_ok $stock, qw/ get objects expire max_objects /;

done_testing;

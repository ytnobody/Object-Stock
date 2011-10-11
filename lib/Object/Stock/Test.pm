use Object::Stock::Test;
use Exporter;
use Data::Dumper;

use strict;

our @ISA = qw/ Exporter /;
our @EXPORT_OK = qw/ build_obj fail_obj show_pattern /;

sub build_obj {
    my ( $stock, %args ) = @_;
    my @caller = caller();
    my $obj = $stock->get( %args );
    isa_ok $obj, 'MyClass';
    ok $obj->{name} eq $args{name} && $obj->{age} == $args{age}, 
        'build_obj'. show_pattern( {%args}, $obj ). show_caller( @caller )
    ;
    return $obj;
}

sub fail_obj {
    my ( $stock, %args ) = @_;
    my @caller = caller();
    my $obj = $stock->get( %args );
    isa_ok $obj, 'MyClass';
    ok $obj->{name} ne $args{name} || $obj->{age} != $args{age}, 
        'fail_obj'. show_pattern( {%args}, $obj ). show_caller( @caller )
    ;
    return $obj;
}

sub show_pattern {
    return "\n=== PATTERN ===\n".Dumper( @_ );
}

sub show_caller {
    return "\n=== CALLER ===\n".Dumper( @_ );
}

1;

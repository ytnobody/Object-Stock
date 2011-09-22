package Object::Stock;
use strict;
use warnings;
use Mouse;
use Mouse::Util::TypeConstraints;
use Time::HiRes ();
use Number::Tolerant;

our $VERSION = '0.01';

subtype Tolerance => as class_type('Number::Tolerant');
coerce 'Tolerance' => 
    from 'Num' => via { tolerance( -1*$_ => to => $_ ) };

has max_objects => ( 
    is      => 'ro', 
    isa     => 'Int', 
    default => 1,
);

has expire => (
    is      => 'ro', 
    isa     => 'Num', 
    default => 0,
);

has expire_tolerance => (
    is      => 'ro', 
    isa     => 'Tolerance',
    default => sub{ tolerance( -0.05 => to => 0.05 ) },
    coerce  => 1,
);

has builder => ( 
    is       => 'ro', 
    isa      => 'CodeRef', 
    required => 1,
);

has identifier => ( 
    is      => 'ro', 
    isa     => 'CodeRef', 
    default => sub { return sub {join '.', @_} },
);

has objects => ( 
    is => 'rw', 
    isa => 'HashRef', 
    clearer => 'flush',
    default => sub {{}},
);

before qw/ get is_stored / => sub {
    my ( $self ) = @_;
    $self->purge_expired;
};

sub create_object {
    my ( $self, @args ) = @_;

    my $id = $self->identifier->( @args );
    my $obj = $self->builder->( @args );

    $self->objects->{"$id"} = { created_on => Time::HiRes::time(), object => $obj };

    $self->purge_overflow;

    return $obj;
}

sub get {
    my ( $self, @args ) = @_;
    return $self->is_stored( @args ) || $self->create_object( @args )
}

sub is_stored {
    my ( $self, @args ) = @_;

    my $id = $self->identifier->( @args );
    return defined $self->objects->{"$id"} ? $self->objects->{"$id"}->{object} : undef;
}

sub purge_expired {
    my $self = shift;

    return unless $self->expire > 0;

    my $now = Time::HiRes::time();

    for my $id ( keys %{ $self->objects } ) {
        my $expired = $now - $self->objects->{"$id"}->{created_on};
        if ( $expired > $self->expire ) {
            my $tolerant = $expired - $self->expire;
            delete $self->objects->{"$id"} if $tolerant != $self->expire_tolerance;
        }
    }
}

sub purge_overflow {
    my $self = shift;

    return unless scalar keys %{$self->objects} > $self->max_objects;

    my @objects ;
    for my $id ( keys %{$self->objects} ) {
        push @objects, { object => $self->objects->{"$id"}, id => $id };
    }
    @objects = sort { $b->{object}->{created_on} <=> $a->{object}->{created_on} } @objects;

    shift @objects for 1 .. $self->max_objects;

    my $id;
    for my $obj ( @objects ) {
        $id = $obj->{id};
        delete $self->objects->{"$id"};
    }
}

no Mouse;

1;
__END__

=head1 NAME

Object::Stock -

=head1 SYNOPSIS

  use Object::Stock;

=head1 DESCRIPTION

Object::Stock is

=head1 AUTHOR

satoshi azuma E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

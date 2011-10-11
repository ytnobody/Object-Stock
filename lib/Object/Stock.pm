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
    return $self->is_stored( @args ) || $self->create_object( @args );
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
    @objects = sort { $a->{object}->{created_on} <=> $b->{object}->{created_on} } @objects;

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

Object::Stock - An object factory

=head1 SYNOPSIS

  # singleton object of LWP::UserAgent
  use Object::Stock;
  
  my $stock = Object::Stock->new(
      builder => sub { LWP::UserAgent->new( @_ ) },
  );
  
  my $obj_x = $stock->get( agent => 'MyAgent/1.0' );
  my $obj_y = $stock->get( agent => 'KoolAgent/0.3' );
  print $obj_x->agent."\n"; # MyAgent/1.0
  print $obj_y->agent."\n"; # KoolAgent/0.3
  $stock->is_stored( agent => 'MyAgent/1.0' ); # TRUE
  $stock->is_stored( agent => 'KoolAgent/0.3' ); # FALSE

  # some objects(LWP::UserAgent) in Object::Stock
  use Object::Stock;
  
  my $stock = Object::Stock->new(
      builder => sub { LWP::UserAgent->new( @_ ) },
      max_objects => 10,
  );
  
  my $obj_x = $stock->get( agent => 'MyAgent/1.0' );
  my $obj_y = $stock->get( agent => 'KoolAgent/0.3' );
  print $obj_x->agent."\n"; # MyAgent/1.0
  print $obj_y->agent."\n"; # KoolAgent/0.3
  $stock->is_stored( agent => 'MyAgent/1.0' ); # TRUE
  $stock->is_stored( agent => 'KoolAgent/0.3' ); # TRUE!!!

=head1 DESCRIPTION

Object::Stock is An object factory class.

Object::Stock identifies objects by their instantiation attributes.

=head1 AUTHOR

satoshi azuma E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

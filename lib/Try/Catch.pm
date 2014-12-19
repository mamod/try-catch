package Try::Catch;
use strict;
use warnings;
use Carp;
use Data::Dumper;
$Carp::Internal{+__PACKAGE__}++;
use base 'Exporter';
our @EXPORT = our @EXPORT_OK = qw(try catch finally);
our $VERSION = 0.002;

sub try(&;@) {
    my $wantarray =  wantarray;
    my $try = shift;
    my $blocks = shift;

    my ($catch, $finally);
    if ($blocks && ref $blocks eq 'HASH'){
        $catch = $blocks->{_try_catch};
        $finally = $blocks->{_try_finally};
    }

    my @ret;
    my $prev_error = $@;
    my $fail = not eval {
        $@ = $prev_error;
        if (!defined $wantarray) {
            $try->();
        } elsif (!$wantarray) {
            $ret[0] = $try->();
        } else {
            @ret = $try->();
        }
        return 1;
    };
    
    my $error = $@;
    my @args = $fail ? ($error) : ();
    
    if ($fail && $catch) {
        my $ret = not eval {
            $@ = $prev_error;
            local $_ = $args[0];
            for ($_){
                if (!defined $wantarray) {
                    $catch->(@args);
                } elsif (!$wantarray) {
                    $ret[0] = $catch->(@args);
                } else {
                    @ret = $catch->(@args);
                }
                last; ## seems to boost speed by 7%
            }
            return 1;
        };

        if ($ret){
            $finally->(@args) if $finally;
            croak $@;
        }
    }

    $@ = $prev_error;
    $finally->(@args) if $finally;
    return $wantarray ? @ret : $ret[0];
}

sub catch(&;@) {
    croak 'Useless bare catch()' unless wantarray;
    my $ret = { _try_catch => shift };
    if (@_) {
        my $prev_block = shift;
        if (ref $prev_block ne 'HASH' || !$prev_block->{_try_finally}){
            croak 'Missing semicolon after catch block ';
        }
        croak 'One catch block allowed' if $prev_block->{_try_catch};
        $ret->{_try_finally} = $prev_block->{_try_finally};
    }
    return $ret;
}

sub finally(&;@) {
    croak 'Useless bare finally()' unless wantarray;
    my $ret = { _try_finally => shift };
    if (@_) {
        my $prev_block = shift;
        if (ref $prev_block ne 'HASH' || !$prev_block->{_try_catch}){
            croak 'Missing semicolon after finally block ';
        }
        croak 'One finally block allowed' if $prev_block->{_try_finally};
        $ret->{_try_catch} = $prev_block->{_try_catch};
    }
    return $ret;
}

1;

__END__
=head1 NAME

Try::Catch - A Try::Tiny copy with speed in mind

=head1 USAGE

Same as Try::Tiny

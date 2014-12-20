package Try::Catch;
use strict;
use warnings;
use Carp;
use Data::Dumper;
$Carp::Internal{+__PACKAGE__}++;
use base 'Exporter';
our @EXPORT = our @EXPORT_OK = qw(try catch finally);
our $VERSION = 0.003;

sub _default_cache {
    croak $_[0];
}

sub try(&;@) {
    my $wantarray =  wantarray;
    my $try       = shift;
    my $caller    = pop;
    my $finally   = pop;
    my $catch     = pop;

    if (!$caller || $caller ne __PACKAGE__){
        croak "syntax error after try block \n" .
                "usage : \n" .
                "try { ... } catch { ... }; \n" .
                "try { ... } finally { ... }; \n" .
                "try { ... } catch { ... } finally { ... }; ";
    }

    #sane behaviour is to throw an error
    #if there is no catch block
    if (!$catch){
        $catch = \&_default_cache;
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
    
    if ($fail) {
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
    if (@_ > 1){
        croak "syntax error after catch block - maybe a missing semicolon"
            if !$_[2] || $_[2] ne __PACKAGE__;
    } else {
        return ( shift,  undef, __PACKAGE__);
    }
    return (@_);
}

sub finally(&;@) {
    croak 'Useless bare finally()' unless wantarray;
    if (@_ > 1) {
        croak "syntax error after finally block - maybe a missing semicolon";
    }
    return ( shift, __PACKAGE__ );
}

1;

__END__
=head1 NAME

Try::Catch - A Try::Tiny copy with speed in mind

=head1 USAGE

Same as Try::Tiny

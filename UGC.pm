package Weather::UGC;
require 5.004;
require Exporter;

=head1 NAME

Weather::UGC - routines for parsing WMO UGC lines

=head1 DESCRIPTION

Weather::UGC is an object for parsing UGC lines in WMO weather products.

=head1 EXAMPLE

    require Weather::UGC;

    $line = "NYZ078>081-NJZ002>004-011-141200-";

    unless (Weather::UGC::valid($line)) {
        die "\'$line\' is not a valid UGC line.\n";
    }

    $ugc = new Weather::UGC($line);

    print $ugc->UGC, " refers to the following zones:\n";
    foreach ($ugc->zones) {
        print $_, "\n";
    }

=head1 AUTHOR

Robert Rothenberg <wlkngowl@unix.asb.com>

=cut

@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw(new expires zones valid);

use vars qw($VERSION $AUTOLOAD);
$VERSION = "1.0.5";

use Carp;

sub initialize {
    my $self = shift;
    $self->{UGC_last} = "";		# Last UGC zone list processed
}

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    $self->initialize();
    $self->import(@_);
    return $self;
}

sub import {
    my $self = shift;
    export $self;

    if (defined($self->{UGC})) {
        croak "UGC already created";
    }

    my $ugc = shift;
    if (defined($ugc)) {
        $self->{UGC} = $ugc;
        unless (valid($ugc)) {
            croak "Invalid UGC: $ugc";
        }
    }
    return $self->{UGC};
}

sub valid {
    my $arg = shift;
    if ($arg =~ m/^([A-Z]{3}\d{3}([\-\>]\d{3}){0,}\-?){1,}\-\d{6}\-/) {
        return 1;
    } else {
        return 0;
    }
}

sub expires {
    my $self = shift;
    my $expiry;

    $self->{UGC} =~ /\-(\d{6})\-?$/;
    $expiry = $1;
    return $expiry;
}

sub zones {
    my $self = shift;
    my @result = ();

    my @ugc_list = (split (/[\-]/, $self->{UGC}));
    my $expiry = pop @ugc_list;
    
    foreach (@ugc_list)
    {
         push @result, $self->ugc_range($_);
    }

    return @result;
}

# this routine is not meant to be called outside of the module
sub ugc_range {
    my $self = shift;
    my ($ugc) = @_;
    my @result = (), $ugc_id, $ugc_from, $ugc_to;

    ($ugc_from, $ugc_to) = split /\>/, $ugc;

    $ugc_from =~ m/^([A-Z]{3})?(\d{3})$/; $ugc_id = $1; $ugc_from = $2; 

    if (defined($ugc_id)) {
         $self{UGC_last} = $ugc_id;
    } else {
         $ugc_id = $self{UGC_last};
    }

    unless (defined($ugc_to)) {
        $ugc_to = $ugc_from;
    }

    if (($ugc_from>$ugc_to) or ($ugc_from !~ /\d{3}/) or ($ugc_to !~ /\d{3}/)) {
        carp "Invalid UGC: $ugc_id$ugc_from\>$ugc_to";
    } else {
        $ugc_from += 0;
        $ugc_to += 0;

        do {            
            push @result, sprintf("%s%03u", $ugc_id, $ugc_from);
        } while ($ugc_from++<$ugc_to);
    }

    return @result;
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self)
                or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion

    unless ($name eq "UGC") {
        croak "Can't access `$name' field in class $type"
    }

    if (@_) {
        return $self->import(@_);
    } else {
        return $self->{$name};
    }
}

1;

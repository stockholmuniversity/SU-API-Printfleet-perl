package SU::API::Printfleet;

use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use HTTP::Request;
use URI::Escape;
use MIME::Base64;
use JSON;
use Carp;


sub new {
    my ($class, $args) = @_;
    my $auth = "Basic " . encode_base64($$args{username} . ":" . $$args{password});
    my $self = {
        hostname    => $$args{hostname},
        auth        => $auth,
        api_version => $$args{api_version} || "3.5.5",
    };
    $self->{url} = "https://$self->{hostname}";
    $self->{ua} = LWP::UserAgent->new;

    bless $self, $class;
    return $self;
}


sub do_request {
    my ($self,$operation,$query) = @_;

    my $content_type = "application/json";
    my $uri = URI->new("https://$self->{hostname}/restapi/$self->{api_version}/$operation");
    $uri->query_form($query);
    my $req = HTTP::Request->new('GET' => "$uri");
    $req->content_type($content_type);
    $req->header( Authorization => $self->{auth} );
    $req->header( Accept => $content_type);
    my $ua = LWP::UserAgent->new;

    my $response = $ua->request($req);
    if ($response->is_success){
        return decode_json($response->decoded_content);
    }else{
        croak $response->status_line;
    }
}

1;

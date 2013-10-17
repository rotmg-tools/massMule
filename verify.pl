#!/usr/local/bin/perl
# from http://www.mpgh.net/forum/655-realm-mad-god-help-requests/738102-anyone-know-http-post-url-2.html#post8811904
#
# configured for gmail server
#
#
#requirements:
# libnet-imap-simple-perl libnet-imap-simple-ssl-perl liburi-find-perl
#
# usage:
# perl verify.pl
#
# to do:
# add threading
# search for unread messages only

use strict;
use warnings;
use LWP::UserAgent;
use Net::IMAP::Simple::SSL;
use URI::Find;

  

my $server = new Net::IMAP::Simple::SSL('imap.gmail.com:993', use_ssl => "true") || die "Unable to connect to IMAP: $Net::IMAP::Simple::SSL::errstr\n";


if(!$server->login('example@gmail.com','password')){
        print STDERR "Login failed: " . $server->errstr . "\n";
        exit(64);
    }

my $i = $server->select('INBOX') + 1;

print "$i messages found";

while ( $i-- ) {
    if ( !$server->seen($i) ) {
        print "message $i";
        my $finder = URI::Find->new( \&acceptVerification );
        my $txt    = $server->get($i);
        $finder->find( \$txt );
    }
}

sub acceptVerification {
    my $uri = shift;
    my $ua  = LWP::UserAgent->new;
    $ua->env_proxy;
    $ua->timeout(30);
    my $tmp;
    if ( $uri =~ /appspot/ ) {
        my $response = $ua->get($uri);
        if ( $response->is_success ) {
            $tmp = $response->decoded_content;
            if ( $tmp =~ /Thank/ ) {
                print "ok\n";
            }
            else {
                print "sux\n";
            }
        }
    }
}

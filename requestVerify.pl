#!/usr/bin/perl -w
#
# mass mule verify request
# based on mass mule password changer v0.2 (c) supahacka@gmail.com

# usage: perl requestVerify.pl mules.txt
# mules.txt format:
# user@domain.com password

use strict;
use warnings;
use threads;
use Thread::Queue;
my $q = Thread::Queue->new(); # A new empty queue

die 'Please specify the filename as a command line argument.' if !defined $ARGV[0];
my $infile=$ARGV[0];

open(INPUT,$infile) or die 'Can not open input file '.$infile.': ' . $! . "\n";
while(<INPUT>){
 chomp();
 my($guid,$password)=split(/\s+/,$_);
 $q->enqueue([$guid, $password]);
}
print $q->pending() . ' mules queued for processing.' . "\n";
sleep 2;

sub start_thread {
 while(my $mule=$q->dequeue_nb()){
  # Format:
  # POST http://realmofthemadgod.appspot.com/account/sendVerifyEmail
  # URLEncoded form
  # guid:         foo@foo.org
  # ignore:       79341
  # password:     futloch
 
  my $content = [
 	'guid' => $mule->[0],
 	'password' => $mule->[1],
 	'ignore' => int(rand(1000)+1000),
  ];
 
  use LWP::UserAgent;
  use HTTP::Request::Common qw(POST);
  my $ua = LWP::UserAgent->new;
  
  my $result=undef;

   my $req = POST 'http://realmofthemadgod.appspot.com/account/sendVerifyEmail', $content;
   my $res = $ua->request($req);
   $result=$res->decoded_content;
   print 'request verify for mule ' . $mule->[0] . '/' . $mule->[1] . ' - result: ' . $result . "\n";
  
 }
}

for(0..2){
 my $thr = threads->create('start_thread');
}

while(threads->list(threads::running)){
 print scalar(localtime(time())) . ' # of threads running: ' . scalar(threads->list(threads::running)) . "\n";
 print $q->pending() . ' mules queued for processing.' . "\n";
 sleep 5;
}

foreach (threads->list(threads::joinable)){
 $_->join();
}

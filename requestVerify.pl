#!/usr/bin/perl -w
#
# mass mule verify request
# based on mass mule password changer v0.2 (c) supahacka@gmail.com

# usage: perl massMuleVerifyRequest.pl mules.txt
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
  # POST https://realmofthemadgod.appspot.com/account/changePassword
  # URLEncoded form
  # guid:         foo@foo.org
  # ignore:       79341
  # newPassword:  futloch2
  # password:     futloch
 
  my $content = [
 	'guid' => $mule->[0],
 	'password' => $mule->[1],
  ];
 
  use LWP::UserAgent;
  use HTTP::Request::Common qw(POST);
  my $ua = LWP::UserAgent->new;
  
  my $retry=1;
  my $timesTried=0;
  my $result=undef;
  while($retry==1){
   my $req = POST 'realmofthemadgod.appspot.com/char/verify', $content;
   my $res = $ua->request($req);
   $result=$res->decoded_content;
   $timesTried++;
   $retry=0 if ($result eq '<Success/>' || $timesTried>=2);
   print 'request verify for mule ' . $mule->[0] . '/' . $mule->[1] . ' to ' . $mule->[2] . ' - result: ' . $result . ($timesTried>1 ? ' (retry #' . $timesTried .' )' : '') . "\n";
  }
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

#!/usr/bin/perl -w
#
# mass mule register
# based on mass mule password changer v0.2 (c) supahacka@gmail.com
# 
#
# usage:
# email pattern, password, mule count
# perl register.pl foo%%%%%@example.com password 10
# % = random number
# $ = random letter
#
# mule names are random letters

use strict;
use warnings;
use threads;
use Thread::Queue;
my $q = Thread::Queue->new(); # A new empty queue

die 'Please specify the email pattern as a command line argument.' if !defined $ARGV[0];
die 'Please specify the password as a command line argument.' if !defined $ARGV[1];
die 'Please specify the number of mules pattern as a command line argument.' if !defined $ARGV[2];
my $guidPattern=$ARGV[0];
my $newPassword=$ARGV[1];
my $muleCount=$ARGV[2];

my $outfile = "mules.txt";

open (MYFILE, ">$outfile") or die 'Can not open output file "mules.txt": ' . $! . "\n";

open (LOGFILE, ">log.txt") or die 'Can not open output file "log.txt": ' . $! . "\n";

for( my $i = 0; $i < $muleCount; $i = $i + 1 ) {

  my $guid = $guidPattern;
  
  while ($guid =~ m/%/ || $guid =~ m/\$/ ) {
    # random numbers and letters    
    my $random_number = int(rand()*10);
    my @letters = ('a'..'z');
    my $random_letter = $letters[int rand @letters];

    $guid =~ s/%/$random_number/;
    $guid =~ s/\$/$random_letter/;
#    print "$guid\n";
  }

  $q->enqueue([$guid, $newPassword]);
}

print $q->pending() . ' mules queued to register.' . "\n";
sleep 2;

sub start_thread {
 while(my $mule=$q->dequeue_nb()){
  # Format:
  # POST https://realmofthemadgod.appspot.com/account/register
  # URLEncoded form
  # guid:         foo@foo.org
  # ignore:       79341
  # newPassword:  futloch2
 


  my $content = [
  #random string
  'guid'=> substr(rand(),-27),
  #email of mule 	
  'newGUID' => $mule->[0],
 	'ignore' => int(rand(1000)+1000),
	'newPassword' => $mule->[1],
  'isAgeVerified' => 1,
  ];
 
  use LWP::UserAgent;
  use HTTP::Request::Common qw(POST);
  my $ua = LWP::UserAgent->new;

  my $registerResult=undef;
  my $req = POST 'http://realmofthemadgod.appspot.com/account/register', $content;
  my $res = $ua->request($req);
  $registerResult=$res->decoded_content;



  my $name="";
  my @letters = ('a'..'z');
    for my $i (0..9) {
    $name .= $letters[int rand @letters];
    }

 $content = [
  #email of mule 	
  'guid' => $mule->[0],
 	'ignore' => int(rand(1000)+1000),
	'password' => $mule->[1],
  'name' => $name,
  ];

  my $nameResult=undef;
  $req = POST 'http://realmofthemadgod.appspot.com/account/setName', $content;
  $res = $ua->request($req);
  $nameResult=$res->decoded_content;


# write out successful mules
if ((index($registerResult, "Success") != -1) && (index($nameResult, "Success") != -1)) {
  my $output = $mule->[0] ." ". $mule->[1]."\n";
  print MYFILE $output;
}

# register mule log output
   my $logoutput = 'register mule: ' . $mule->[0] . '/' . $mule->[1] .' - registerResult: ' . $registerResult . ' name: '.$name.' - nameResult: ' . $nameResult . "\n";
  print $logoutput;
  print LOGFILE $logoutput;
  
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

close (MYFILE); 
close (LOGFILE); 

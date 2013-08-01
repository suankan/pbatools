#!/usr/bin/perl

use lib '/usr/local/bm/tools';
use strict;
use Switch;
use db;

my $action = $ARGV[0];

switch ($action){
  case "--help" {
    print "Usage: \
  update_descriptions.pl --store-descr file.csv PlanID \
    Updates Store descriptions in PlanID for resources specified in file.csv. \
    file.csv should be a list of comma-separated pairs: ResourceName,StoreDescription\n
  update_descriptions.pl --res-descr file.csv PlanID \
    Updates Recurring|Overuse Fee descriptions in PlanID for resoruces specified in file.csv \
    file.csv should be a list of comma-separated values: ResourceName,RecurringFeeDescription,OveruseFeeDescription\n";
  }
  case "--store-descr" {
    update_store_descriptions($ARGV[1], $ARGV[2]);
  }
  case "--res-descr" {
    update_resoruce_descriptions($ARGV[1], $ARGV[2]);
  }
}

sub trim_spaces {
  my $string = shift;
  $string =~ s/^\s*//;
  $string =~ s/\s*$//;
  return $string;
}

sub update_store_descriptions {
  print "Using Store descriptions from file ", my $filepath = shift, "\n";
  print "Updating Store descriptions for resoruces in Plan ", my $PlanID = shift, "\n";
  open FILE, "$filepath" or die $!;
  while (my $line = <FILE>){
    my @data = split(',', $line);
    my $ResourceName = trim_spaces($data[0]);
    my $RawStoreDescr = trim_spaces($data[1]);
    my $StoreDescr = "en $RawStoreDescr\t";
    db::connect();
    db::do(
      "UPDATE `PlanRate`
       SET `StoreText`=?
       FROM `BMResource`
       WHERE `PlanRate`.`resourceID`=`BMResource`.`resourceID`
       AND `BMResource`.`name`=?
       AND `PlanRate`.`PlanID`=?",
       $StoreDescr,
       $ResourceName,
       $PlanID
    ) unless ($StoreDescr eq "");
    db::commit();
  };
  close(FILE);
}

sub update_resoruce_descriptions {
  while (my $line = <FILE>) {
    my @data = split(',', $line);
    print my $ResourceName = trim_spaces($data[0]);
    print my $DescriptionRecurring = trim_spaces($data[1]);
    print my $DescriptionOveruse = trim_spaces($data[2]);
=pod
    db::do(
      "UPDATE `PlanRate`
       SET `RecurrFeeDescr`=?
       FROM `BMResource`
       WHERE `PlanRate`.`resourceID`=`BMResource`.`resourceID`
       AND `BMResource`.`name`=?
       AND `PlanRate`.`PlanID`=?",
      $DescriptionRecurring,
      $ResourceName,
      $PlanID
    ) unless ($DescriptionRecurring eq "");

    db::do(
      "UPDATE `PlanRate`
      SET `OveruseFeeDescr`=?
      FROM `BMResource`
      WHERE `PlanRate`.`resourceID`=`BMResource`.`resourceID`
      AND `BMResource`.`name`=?
      AND `PlanRate`.`PlanID`=?",
      $DescriptionOveruse,
      $ResourceName,
      $PlanID
    ) unless ($DescriptionOveruse eq "");
=cut
  };
}

1;

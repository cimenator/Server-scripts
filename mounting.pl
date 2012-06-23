#!/usr/bin/perl

use warnings;
use strict;
use File::Path qw(make_path remove_tree);
use Switch;

print "Montowanie katalogów\n";

my @dane;

wczytaj();

print (@dane);
print "\n";

montuj();
#listaZamontowanych();

print "\n";
exit(0);

sub wczytaj
{
	my $plik = 'katalogi';
	
	open (PLIK, $plik);
	while (<PLIK>)
	{
		push @dane, $_ unless ($_ =~ /^#/);
	}
	close(PLIK);
}

sub montuj
{
	foreach (@dane)
	{
		my @tmp = split(':', $_);
		my $katalog = trim($tmp[0]);
		my $puntkMontowania = trim($tmp[1]);
		
		unless (-d $katalog)
		{
			print "Katalog: $katalog nie istnieje\n";
			next;
		}
		
		unless (-d $puntkMontowania)
		{
			print "Punkt montowania: $puntkMontowania nie istnieje\n";
			make_path($puntkMontowania, {
				verbose => 0,
				mode => 0777,
			});
		}
		
		my @polecenie = ("mount", "--bind", $katalog, $puntkMontowania);
		if (system(@polecenie) == 0)
		{
			print "Katalog $katalog w miejscu $puntkMontowania\n";
		}
		else
		{
			print "Blad montowania $katalog w miejscu $puntkMontowania\n";
		}
	}
}

sub listaZamontowanych
{
	my @zamontowane = `mount | awk '\$6 ~ "bind" { print \$0 }'`;
	
	print "Lista zamontowanych katalogow:\n";
	print @zamontowane;
}

sub odmontuj
{
	
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


package Crypt::Vigenere;

use strict;

sub new {
	my $class = shift;
	my $keyword = shift || '';

	if( $keyword !~ /^[A-Za-z]+$/ ) {
		die "Error: The keyword may only contain letters\n";
	};

	my $self = {
		'keyword' => $keyword,
	};
	bless $self, $class;

	$self->_init( $keyword );

	return( $self );
};

sub _init {
	my $self = shift;

	foreach ( split('', lc($self->{keyword})) ) {
		my $ks = (ord($_)-18) % 26;
		my $ke = $ks - 1;
 
		my ($s, $S, $e, $E);
 
		$s = chr(ord('a') + $ks);
		$S = chr(ord('A') + $ks);
		$e = chr(ord('a') + $ke);
		$E = chr(ord('A') + $ke);

		push @{$self->{fwdLookupTable}}, "a-zA-Z/$s-za-$e$S-za-$E";
		push @{$self->{revLookupTable}}, "$s-za-$e$S-za-$E/a-zA-Z";
	};

	return( $self );
};

sub encodeMessage {
	my $self = shift;
	my $string = shift;
	return( $self->_doTheMath($string, $self->{fwdLookupTable}) );
};

sub decodeMessage {
	my $self = shift;
	my $string = shift;
	return( $self->_doTheMath($string, $self->{revLookupTable}) );
};


sub _doTheMath {
	my $self = shift;
	my $string = shift;
	my $lookupTable = shift;
	my $returnString;

	my $count = 0;
	foreach( split('', $string) ) {
		if( /[a-zA-Z]{1}/ ) {
			eval "\$_ =~ tr/$lookupTable->[$count % 4]/";
			$count++;
		}
		$returnString .= $_;
	};

	return( $returnString );
};


package Crypt::Substitution::PolyAlphabetic;

use strict;

sub generateLookupTables {
	my $class = shift;
	my $keyword = lc(shift);
	my $fwdLookupTables = {};
	my $revLookupTables = {};
	my $letters = [];

	my $stdLookupTable = [
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 
		'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	];

	@{$letters} = split('', $keyword);

	foreach my $letter ( @{$letters} ) {
		my $bespokeLookupTable;
		@{$bespokeLookupTable} = @{$stdLookupTable};
		my $count = 0;
		while( $letter ne $stdLookupTable->[$count] ) {
			my $temp = shift @{$bespokeLookupTable};
			push @{$bespokeLookupTable}, $temp;
			$count++
		};

		$count = 0;
		foreach( @{$bespokeLookupTable} ) {
			$fwdLookupTables->{$letter}->{$stdLookupTable->[$count]} = $_;
			$revLookupTables->{$letter}->{$_} = $stdLookupTable->[$count];
			$count++;
		};
	};

	return( $fwdLookupTables, $revLookupTables );
};


1;

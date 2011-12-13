package Padre::Wx::Dialog::Replace;

use 5.008;
use strict;
use warnings;
use Padre::Search           ();
use Padre::Wx::FBP::Replace ();

our $VERSION = '0.93';
our @ISA     = 'Padre::Wx::FBP::Replace';

use constant GOOD => Wx::SystemSettings::GetColour( Wx::SYS_COLOUR_WINDOW );
use constant BAD  => Wx::Colour->new(
	GOOD->Red,
	int( GOOD->Green * 0.5 ),
	int( GOOD->Blue  * 0.5 ),
);





######################################################################
# Constructor

sub new {
	my $class = shift;
	my $self  = $class->SUPER::new(@_);

	# Prepare to be shown
	$self->CenterOnParent;

	return $self;
}





######################################################################
# Main Methods

sub run {
	my $self    = shift;
	my $main    = $self->main;
	my $current = $self->current;
	my $config  = $current->config;

	# Do they have a specific search term in mind?
	my $text = $current->text;
	unless ( defined $text ) {
		$text = '';
	}
	unless ( length $text ) {
		if ( $main->has_findfast and $main->findfast->visible ) {
			my $fast = $main->findfast->find_term;
			$text = $fast if length $fast;	
		}
	}
	if ( $text =~ /\n/ ) {
		$text = '';
	}

	# Clear out and reset the search term box
	$self->{find_term}->refresh($text);
	if ( length $text ) {
		$self->{replace_term}->SetFocus;
	} else {
		$self->{find_term}->SetFocus;
	}

	# Do an initial refresh to hide unusable buttons
	$self->refresh;

	# Hide the Fast Find if visible
	$main->show_findfast(0);

	# Show the dialog
	$self->Show;
}





######################################################################
# Event Handlers

# Makes sure the find button is only enabled when the field
# values are valid
sub refresh {
	my $self = shift;
	my $lock = Wx::WindowUpdateLocker->new( $self->{find_term} );

	if ( $self->as_search ) {
		$self->{find_term}->SetBackgroundColour(GOOD);
		$self->{find_next}->Enable(1);
		$self->{replace}->Enable(1);
		$self->{replace_all}->Enable(1);
		
	} else {
		if ( $self->{find_term}->GetValue ne '' ) {
			$self->{find_term}->SetBackgroundColour(BAD);
		} else {
			$self->{find_term}->SetBackgroundColour(GOOD);
		}
		$self->{find_next}->Enable(0);
		$self->{replace}->Enable(0);
		$self->{replace_all}->Enable(0);
	}

	return;
}

sub find_next_clicked {
	my $self = shift;
	my $main = $self->main;

	# Generate the search object
	my $search = $self->as_search;
	unless ($search) {
		$main->error('Not a valid search');

		# Move the focus back to the search text
		# so they can tweak their search.
		$self->{find_term}->SetFocus;
		return;
	}

	# Apply the search to the current editor
	if ( $main->search_next($search) ) {
		$self->{find_term}->SaveValue;
	}

	return;
}

sub replace_clicked {
	my $self = shift;

}

sub replace_all_clicked {
	my $self = shift;
	my $main = $self->main;

	# Generate the search object
	my $search = $self->as_search;
	unless ($search) {
		$main->error('Not a valid search');
		return;
	}

	# Apply the search to the current editor
	my $changes = $main->replace_all($search);
	if ($changes) {
		my $message_text =
			$changes == 1 ? Wx::gettext('Replaced %d match') : Wx::gettext('Replaced %d matches');

		# remark: It would be better to use gettext for plural handling, but wxperl does not seem to support this at the moment.
		$main->info(
			sprintf( $message_text, $changes ),
			Wx::gettext('Search and Replace')
		);
	} else {
		$main->info(
			sprintf( Wx::gettext('No matches found for "%s".'), $self->{find_text}->GetValue ),
			Wx::gettext('Search and Replace'),
		);
	}

	# Move the focus back to the search text
	# so they can change it if they want.
	$self->{find_text}->SetFocus;
	return;
}





######################################################################
# Support Methods

# Generate a search object for the current dialog state
sub as_search {
	my $self = shift;
	Padre::Search->new(
		find_term    => $self->{find_term}->GetValue,
		find_case    => $self->{find_case}->GetValue,
		find_regex   => $self->{find_regex}->GetValue,
		replace_term => $self->{replace_term}->GetValue,
	);
}

1;

# Copyright 2008-2011 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.

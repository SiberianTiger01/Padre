package Padre::Wx::FBP::Bookmarks;

## no critic

# This module was generated by Padre::Plugin::FormBuilder::Perl.
# To change this module edit the original .fbp file and regenerate.
# DO NOT MODIFY THIS FILE BY HAND!

use 5.008005;
use utf8;
use strict;
use warnings;
use Padre::Wx ();
use Padre::Wx::Role::Main ();

our $VERSION = '0.95';
our @ISA     = qw{
	Padre::Wx::Role::Main
	Wx::Dialog
};

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		Wx::gettext("Bookmarks"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
		Wx::DEFAULT_DIALOG_STYLE,
	);

	$self->{set_label} = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("Set Bookmark:"),
	);
	$self->{set_label}->Hide;

	$self->{set} = Wx::TextCtrl->new(
		$self,
		-1,
		"",
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);
	$self->{set}->Hide;

	$self->{set_line} = Wx::StaticLine->new(
		$self,
		-1,
		Wx::DefaultPosition,
		Wx::DefaultSize,
		Wx::LI_HORIZONTAL,
	);
	$self->{set_line}->Hide;

	$self->{m_staticText2} = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("Existing Bookmarks:"),
	);

	$self->{list} = Wx::ListBox->new(
		$self,
		-1,
		Wx::DefaultPosition,
		Wx::DefaultSize,
		[],
		Wx::LB_NEEDED_SB | Wx::LB_SINGLE,
	);

	my $m_staticline1 = Wx::StaticLine->new(
		$self,
		-1,
		Wx::DefaultPosition,
		Wx::DefaultSize,
		Wx::LI_HORIZONTAL,
	);

	$self->{ok} = Wx::Button->new(
		$self,
		Wx::ID_OK,
		Wx::gettext("OK"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);
	$self->{ok}->SetDefault;

	$self->{delete} = Wx::Button->new(
		$self,
		-1,
		Wx::gettext("&Delete"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);

	Wx::Event::EVT_BUTTON(
		$self,
		$self->{delete},
		sub {
			shift->delete_clicked(@_);
		},
	);

	$self->{delete_all} = Wx::Button->new(
		$self,
		-1,
		Wx::gettext("Delete &All"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);

	Wx::Event::EVT_BUTTON(
		$self,
		$self->{delete_all},
		sub {
			shift->delete_all_clicked(@_);
		},
	);

	my $cancel = Wx::Button->new(
		$self,
		Wx::ID_CANCEL,
		Wx::gettext("Cancel"),
		Wx::DefaultPosition,
		Wx::DefaultSize,
	);

	my $existing = Wx::BoxSizer->new(Wx::HORIZONTAL);
	$existing->Add( $self->{m_staticText2}, 0, Wx::ALL, 5 );

	my $buttons = Wx::BoxSizer->new(Wx::HORIZONTAL);
	$buttons->Add( $self->{ok}, 0, Wx::ALL, 5 );
	$buttons->Add( $self->{delete}, 0, Wx::ALL, 5 );
	$buttons->Add( $self->{delete_all}, 0, Wx::ALL, 5 );
	$buttons->Add( 20, 0, 1, Wx::EXPAND, 5 );
	$buttons->Add( $cancel, 0, Wx::ALL, 5 );

	my $vsizer = Wx::BoxSizer->new(Wx::VERTICAL);
	$vsizer->Add( $self->{set_label}, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::LEFT | Wx::RIGHT | Wx::TOP, 5 );
	$vsizer->Add( $self->{set}, 0, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $self->{set_line}, 0, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $existing, 1, Wx::EXPAND, 5 );
	$vsizer->Add( $self->{list}, 0, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $m_staticline1, 0, Wx::ALL | Wx::EXPAND, 5 );
	$vsizer->Add( $buttons, 0, Wx::EXPAND, 5 );

	$self->{sizer} = Wx::BoxSizer->new(Wx::HORIZONTAL);
	$self->{sizer}->Add( $vsizer, 1, Wx::ALL | Wx::EXPAND, 5 );

	$self->SetSizerAndFit($self->{sizer});
	$self->Layout;

	return $self;
}

sub set_label {
	$_[0]->{set_label};
}

sub set {
	$_[0]->{set};
}

sub set_line {
	$_[0]->{set_line};
}

sub list {
	$_[0]->{list};
}

sub ok {
	$_[0]->{ok};
}

sub delete {
	$_[0]->{delete};
}

sub delete_all {
	$_[0]->{delete_all};
}

sub delete_clicked {
	$_[0]->main->error('Handler method delete_clicked for event delete.OnButtonClick not implemented');
}

sub delete_all_clicked {
	$_[0]->main->error('Handler method delete_all_clicked for event delete_all.OnButtonClick not implemented');
}

1;

# Copyright 2008-2012 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.


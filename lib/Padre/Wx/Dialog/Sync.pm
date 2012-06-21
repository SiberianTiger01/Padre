package Padre::Wx::Dialog::Sync;

use 5.008;
use strict;
use warnings;
use Padre::ServerManager ();
use Padre::Wx::FBP::Sync ();
use Padre::Logger;

our $VERSION = '0.97';
our @ISA     = 'Padre::Wx::FBP::Sync';

sub new {
	my $class  = shift;
	my $self   = $class->SUPER::new(@_);
	my $config = $self->config;

	# Fill form elements from configuration
	$self->{txt_remote}->SetValue( $config->config_sync_server );
	$self->{login_email}->SetFocus;
	$self->{login_email}->SetValue( $config->identity_email );
	$self->{login_password}->SetValue( $config->config_sync_password );

	# Registration prefill
	unless ( $config->config_sync_password ) {
		$self->{txt_email}->SetValue( $config->identity_email );
		$self->{txt_email_confirm}->SetValue( $config->identity_email );
	}

	# Create the sync manager and subscribe to events
	$self->{server_manager} = Padre::ServerManager->new(
		ide => $self->ide,
	);
	$self->{server_manager}->subscribe( $self, {
		server_version => 'server_version',
		server_error   => 'server_error',
	} );

	# Update form to match sync manager
	$self->refresh;

	return $self;
}

sub run {
	my $class = shift;
	my $main  = shift;
	my $self  = $class->new($main);

	# Trigger a server version check
	$self->server_check;

	# Show the dialog
	$self->ShowModal;

	return 1;
}




######################################################################
# Event Handlers

sub btn_login {
	my $self = shift;
	my $server = $self->{server_manager};

	my $url = $self->{txt_remote}->GetValue;
	if ( $url ne $self->config->config_sync_server ) {
		$self->config->apply( 'config_sync_server' => $url );
	}

	my $username = $self->{login_email}->GetValue;
	my $password = $self->{login_password}->GetValue;

	# Handle login / logout logic toggle
	if ( $server->{state} eq 'logged_in' ) {
		if ( $server->logout =~ /success/ ) {
			Wx::MessageBox(
				sprintf('Successfully logged out.'),
				Wx::gettext('Error'),
				Wx::OK,
				$self,
			);
			$self->{btn_login}->SetLabel('Log in');
		} else {
			Wx::MessageBox(
				sprintf('Failed to log out.'),
				Wx::gettext('Error'),
				Wx::OK,
				$self,
			);
		}

		$self->{lbl_status}->SetLabel( $self->server_status );
		return;
	}

	unless ( $username and $password ) {
		Wx::MessageBox(
			sprintf( Wx::gettext('Please input a valid value for both username and password') ),
			Wx::gettext('Error'),
			Wx::OK,
			$self,
		);
		return;
	}

	# Attempt login
	my $rc = $server->login(
		username => $username,
		password => $password,
	);

	$self->refresh;

	# Print the return information
	Wx::MessageBox(
		sprintf( '%s', $rc ),
		Wx::gettext('Error'),
		Wx::OK,
		$self,
	);
}

sub btn_register {
	my $self             = shift;
	my $email            = $self->{txt_email}->GetValue;
	my $email_confirm    = $self->{txt_email_confirm}->GetValue;
	my $password         = $self->{txt_password}->GetValue;
	my $password_confirm = $self->{txt_password_confirm}->GetValue;

	# Validation of inputs
	unless ( $email and $email_confirm and $password and $password_confirm ) {
		Wx::MessageBox(
			sprintf( Wx::gettext('Please ensure all inputs have appropriate values.') ),
			Wx::gettext('Error'),
			Wx::OK,
			$self,
		);
		return;
	}

	# Not sure if password quality rules should be enforced at this level?
	unless ( $password eq $password_confirm ) {
		Wx::MessageBox(
			sprintf( Wx::gettext('Password and confirmation do not match.') ),
			Wx::gettext('Error'),
			Wx::OK,
			$self,
		);
		return;
	}

	unless ( $email eq $email_confirm ) {
		Wx::MessageBox(
			sprintf( Wx::gettext('Email and confirmation do not match.') ),
			Wx::gettext('Error'),
			Wx::OK,
			$self,
		);
		return;
	}

	# Attempt registration
	my $rc = $self->{server_manager}->register(
		email            => $email,
		email_confirm    => $email_confirm,
		password         => $password,
		password_confirm => $password_confirm,
	);

	# Print the return information
	Wx::MessageBox(
		sprintf( '%s', $rc ),
		Wx::gettext('Error'),
		Wx::OK,
		$self,
	);
}

sub btn_local {
	my $self = shift;
	my $rc   = $self->{server_manager}->local_to_server;
	Wx::MessageBox(
		sprintf( '%s', $rc ),
		Wx::gettext('Error'),
		Wx::OK,
		$self,
	);
}

sub btn_remote {
	my $self = shift;
	my $rc   = $self->{server_manager}->server_to_local;
	Wx::MessageBox(
		sprintf( '%s', $rc ),
		Wx::gettext('Error'),
		Wx::OK,
		$self,
	);
}

sub btn_delete {
	my $self = shift;
	my $rc   = $self->{server_manager}->server_delete;
	Wx::MessageBox(
		sprintf( '%s', $rc ),
		Wx::gettext('Error'),
		Wx::OK,
		$self,
	);

}

# Save changes to dialog inputs to config
sub btn_ok {
	my $self   = shift;
	my $config = $self->current->config;

	# Save the server access defaults
	$config->set( config_sync_server   => $self->{txt_remote}->GetValue );
	$config->set( identity_email       => $self->{login_email}->GetValue );
	$config->set( config_sync_password => $self->{login_password}->GetValue );

	$self->Destroy;
}





######################################################################
# Server Checks

sub server_check {
	TRACE("Launching server check") if DEBUG;
	my $self = shift;
	$self->{txt_remote}->SetBackgroundColour($self->base_colour);
	$self->{server_manager}->version;
	return 1;
}
	
sub server_version {
	TRACE("Got server_version callback") if DEBUG;
	my $self = shift;
	$self->{server_version} = $_[1];
	$self->{txt_remote}->SetBackgroundColour($self->good_colour);
	return 1;
}

sub server_error {
	TRACE("Got server_error callback") if DEBUG;
	my $self   = shift;
	$self->{txt_remote}->SetBackgroundColour($self->bad_colour);
	return 1;
}





################################################################################
# GUI Methods

sub refresh {
	my $self = shift;
	my $server = $self->{server_manager};

	# Refresh the server status elements
	$self->refresh_server;

	# Are we logged in?
	my $in = $server->{state} eq 'logged_in' ? 1 : 0;
	$self->{btn_login}->SetLabel( $in ? 'Logout' : 'Login' );
	$self->{btn_local}->Enable($in);
	$self->{btn_remote}->Enable($in);
	$self->{btn_delete}->Enable($in);

	return 1;
}

sub refresh_server {
	my $self    = shift;
	my $manager = $self->{server_manager};
	if ( $manager->user ) {
		$self->{lbl_status}->SetLabel("Logged In");
	} elsif ( $manager->server ) {
		$self->{lbl_status}->SetLabel("Logged Out");
	} else {
		$self->{lbl_status}->SetLabel("Server Unknown");
	}
	return 1;
}

sub base_colour {
	Wx::SystemSettings::GetColour(Wx::SYS_COLOUR_WINDOW);
}

sub good_colour {
	my $self = shift;
	my $base = $self->base_colour;
	return Wx::Colour->new(
		int( $base->Red * 0.5 ),
		$base->Green,
		int( $base->Blue * 0.5 ),
	);
}

sub bad_colour {
	my $self = shift;
	my $base = $self->base_colour;
	return Wx::Colour->new(
		$base->Red,
		int( $base->Green * 0.5 ),
		int( $base->Blue * 0.5 ),
	);
}

1;

# Copyright 2008-2012 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.

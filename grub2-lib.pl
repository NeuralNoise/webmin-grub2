#!/usr/bin/perl
# grub2-lib.pl
# Common functions for GRUB2 configuration

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Basename;
use Data::Dumper;#**use Data::Printer;
use Text::Balanced qw (
	extract_delimited
	extract_bracketed
	extract_quotelike
	extract_codeblock
	extract_variable
	extract_tagged
	extract_multiple
	gen_delimited_pat
	gen_extract_tagged
);
init_config();

my $output = &backquote_command("(grub2-install -V) 2>&1");
our $version = (split ' ', $output)[2];

#our $server_root = $config{'nginx_dir'};
#our %ginfo = &get_grub2_info();

# gets environment
sub get_grub2_env
{
	my $output = &backquote_command("(grub2-editenv list) 2>&1");
	my @args = split /\n/, $output;
	my %vars = map { split /=/, $_, 2 } @args;
	return %vars;
}

# get commands hash of arrays
sub get_cmds
{
	%cmds = (
		"grub2-bios-setup" => {			desc => "Set up images to boot from a device.",											version => ''},
		"grub2-editenv" => {			desc => "Manage the GRUB environment block.",											version => ''},
		"grub2-file" => {				desc => "Check if FILE is of specified type.",											version => ''},
		"grub2-glue-efi" => {			desc => "Create an Apple fat EFI binary.",												version => ''},
		"grub2-install" => {			desc => "Install GRUB on a device.",													version => ''},
		"grub2-kbdcomp" => {			desc => "Generate a GRUB keyboard layout file.",										version => ''},
		"grub2-macbless" => {			desc => "Mac-style bless utility for HFS or HFS+",										version => ''},
		"grub2-menulst2cfg" => {		desc => "Convert a configuration file from GRUB 0.xx to GRUB 2.xx format.",				version => ''},
		"grub2-mkconfig" => {			desc => "Generate a GRUB configuration file.",											version => ''},
		"grub2-mkfont" => {				desc => "Convert common font file formats into the PF2 format.",						version => ''},
		"grub2-mkimage" => {			desc => "Make a bootable GRUB image.",													version => ''},
		"grub2-mklayout" => {			desc => "Generate a GRUB keyboard layout file.",										version => ''},
		"grub2-mknetdir" => {			desc => "Prepare a GRUB netboot directory.",											version => ''},
		"grub2-mkpasswd-pbkdf2" => {	desc => "Generate a PBKDF2 password hash.",												version => ''},
		"grub2-mkrelpath" => {			desc => "Generate a relative GRUB path given an OS path.",								version => ''},
		"grub2-mkrescue" => {			desc => "Generate a GRUB rescue image using GNU Xorriso.",								version => ''},
		"grub2-mkstandalone" => {		desc => "Generate a standalone image in the selected format.",							version => ''},
		"grub2-ofpathname" => {			desc => "Generate an IEEE-1275 device path for a specified device.",					version => ''},
		"grub2-probe" => {				desc => "Probe device information for a given path.",									version => ''},
		"grub2-reboot" => {				desc => "Set the default boot menu entry for the next boot only.",						version => ''},
		"grub2-render-label" => {		desc => "Render an Apple disk label.",													version => ''},
		"grub2-rpm-sort" => {			desc => "Sort input according to RPM version compare.",									version => ''},
		"grub2-script-check" => {		desc => "Check GRUB configuration file for syntax errors.",								version => ''},
		"grub2-set-default" => {		desc => "Set the default boot menu entry for GRUB.",									version => ''},
		"grub2-setpassword" => {		desc => "Generate the user.cfg file containing the hashed grub bootloader password.",	version => ''},
		"grub2-sparc64-setup" => {		desc => "Set up a device to boot a sparc64 GRUB image.",								version => ''},
		"grub2-syslinux2cfg" => {		desc => "Transform a syslinux config file into a GRUB config.",							version => ''},
		"grub2-fstest" => {				desc => "(unknown subject)",															version => ''},
		"grubby" => {					desc => "command line tool for configuring grub, lilo, elilo, yaboot and zipl",			version => ''},
	);
	foreach my $a (keys \%cmds) {
		$output = &backquote_command($a." -V 2>&1");
		$cmds{$a}{'version'} = (split ' ', $output)[2];
		if ($cmds{$a}{'version'} !~ /\d/) {
			$cmds{$a}{'version'} = $text{'noversion'};
		}
	}
	return %cmds
}

sub update_button
{
	my $rv;
	$args = "redir=".&urlize(&this_url());
	my @rv;
	if (&is_nginx_running()) {
		push(@rv, "<a href=\"restart.cgi?$args\">$text{'grub2_apply'}</a>\n");
		push(@rv, "<a href=\"stop.cgi?$args\">$text{'grub2_stop'}</a>\n");
	} else {
		push(@rv, "<a href=\"start.cgi?$args\">$text{'grub2_start'}</a>\n");
	}
	return join("<br>\n", @rv);
}

# test config files
sub test_config
{
  return undef;
  if ($config{'test_config'} == 1) {
    my $out = &backquote_command("(/etc/init.d/grub2 configtest) 2>&1");
    if ($out =~ /failed/) {
      return "<pre>".&html_escape($out)."</pre>";
    }
    else {
#    elsif ($out =~ /successful/) {
      return undef;
    }
    return $text{'test_err'};
  }
  return undef;
}

;1
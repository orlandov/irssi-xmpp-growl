use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.01";
%IRSSI = (
    authors     => 'Orlando Vazquez',
    contact     => 'ovazquez@gmail.com',
    name        => 'xnmpp-notify',
    description => 'Use growlnotify to alert user to hilighted messages',
);

sub shell_escape {
    my $str = shift;

    $str =~ s/\\/\\\\/gm;
    $str =~ s/\n/\\\n/gm;
    $str =~ s/\$/\\\$/gm;
    $str =~ s/\#/\\\#/gm;
    $str =~ s/\(/\\\(/gm;
    $str =~ s/\)/\\\)/gm;
    $str =~ s/</\</gm;
    $str =~ s/>/\>/gm;

    $str =~ s/'/\\'/gm;
    $str =~ s/`/\\`/g;
    $str =~ s/"/\\"/gm;
    $str =~ s/!/\\!/gm;

    return $str;
}

sub notify {
    my ($server, $summary, $message) = @_;

    $message = shell_escape($message);
    $summary = shell_escape($summary);

    my $cmd = "EXEC - growlnotify -m \"$message\" \"$summary\"";
    $server->command($cmd);
}

sub print_text_notify {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};

    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    my $sender = $stripped;
    $sender =~ s/^\<.([^\>]+)\>.+/\1/ ;
    $stripped =~ s/^\<.[^\>]+\>.// ;
    my $summary = $dest->{target} . ": " . $sender;
    notify($server, $summary, $stripped);
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;

    return if (!$server);
    notify($server, "Private message from ".$nick, $msg);
}

sub dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$dcc);
    notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');

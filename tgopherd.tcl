#!/usr/bin/env tclsh8.6

# This file is the main one. We get our listener routine and our error routine from here.
#Also command interpretment.

package require json

set c [list]

proc define {macro value} {
	set [format "::%s" $macro] $value
}

source tgopherd.tcl.h

proc tgd:fmt-line {type selector path host {port 70} {plus {}}} {
	if {$plus == {}} {set tabs ""} {set tabs "\t"}
	format "%s%s\t%s\t%s\t%s%s%s" $type $selector $path $host $port $tabs $plus
}

proc tgd:sendbinaryfile {channel file} {
	fconfigure $channel -translation binary
	# XXX - no way to send a file
}

proc tgd:acceptconn {vhost channel addr port} {
	puts stdout [format "accepted connection from %s" $addr]
	fconfigure $channel -translation {auto crlf} -buffersize 1024 -buffering line
	fileevent $channel readable [list tgd:readable $channel $vhost $addr $port]
}

proc tgd:server {name state} {
	dict set ::c vserver $name enabled 1
	foreach {k v} $::DEFAULT_STATE {
		dict set ::c vserver $name {*}$k $v
	}
	foreach {k v} $state {
		dict set ::c vserver $name {*}$k $v
	}
	set port [tgd:vc $name port]
	set host [tgd:vc $name bind]
	if {$host != {}} {socket -server [list tgd:acceptconn $name] -myaddr $host $port} {
		socket -server [list tgd:acceptconn $name] $port
	}
}

proc tgd:vc {v args} {
	dict get $::c vserver $v {*}$args
}

proc tgd:readable {c v a p} {
	set gotten [gets $c line]
	if {$gotten >= 0} {
		puts stdout [format "received a Gopher request for .%s. from %s (vserver %s)" [lindex [split $line "\t"] 0] $a $v]
		puts $c [tgd:fmt-line $::type_error "Go away. This server doesn't work yet." / 127.0.0.1 [tgd:vc $v port]]
	}
	close $c
}

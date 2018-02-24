# "header" of sorts

foreach {k v} {
text	0
menu	1
error	3
gzip	5
query	7
binary	9
gif	g
html	h
info	i
picture	I
mbox	M
doc	d
title	!
} {define [format "type_%s" $k] $v}

set DEFAULT_STATE {
port				70
apparentport			70
bind				127.0.0.1
vhost				unconfigured.gopher
root				/home/hadron/src/gopher-root
gophermap			Gmap
gopherheader			.Ghdr
gophertag			.Gtag
gopherfooter			.Gftr
x-s-gopher-selector-method	plus
}

#!/usr/bin/env tclsh8.6

set cfgcount [dict create]

proc [namespace current]::createconfigblock {name validdirectives {multi 0}} {
	namespace eval [namespace current]::$name {}
	set [namespace current]::${name}::validdirectives $validdirectives
	set [namespace current]::${name}::multi $multi

	namespace eval [namespace current]::$name {
		variable opts [dict create]

		foreach directive $validdirectives {
			set blockproc {variable opts
				set directive [namespace tail [dict get [info frame 0] proc]]
				set count [set [namespace current]::count]
			}
			if {[set multi]} {
				append blockproc [format {dict set opts $%s opts $%s $%s%s} count directive args "\n"]
			} {
				append blockproc [format {dict set opts %s $%s%s} $directive args "\n"]
			}
			proc [namespace current]::$directive {args} $blockproc
		}
	}

	set blockproc {
		set name [namespace tail [dict get [info frame 0] proc]]
	}

	if {$multi} {
		append blockproc [format "dict incr ::cfgcount \$%s\n" name]
		append blockproc [format "set count \[dict get \$%s \$%s\]" ::cfgcount name]
		append blockproc {
			if {[llength $args] > 1} {
				dict set [namespace current]::${name}::opts $count headlines [lrange $args 0 end-1]
			}
		}
	} {
		append blockproc "set count 0\n"
		append blockproc {
			if {[llength $args] > 1} {
				set [namespace current]::${name}::headlines [lrange $args 0 end-1]
			}
		}
	}
	append blockproc {
		set [namespace current]::${name}::count $count
		::apply [list {count} [lindex $args end] [namespace current]::$name] $count
	}
	proc $name {args} $blockproc
}

#createconfigblock serverinfo [list name desc id] 1
#source "random.conf.tcl"

#foreach {bnum block} [set [namespace current]::serverinfo::opts] {
#	puts stdout [format "On block number %s," $bnum]
#	puts stdout [format "You chose serverinfo::name \"%s\" and the headlines are \"%s\"" [dict get $block opts name] [join [dict get $block headlines] {" "}]]
#}

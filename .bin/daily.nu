#!/usr/bin/env nu

let note_dir = $"($env.HOME)/Notes"
let daily_dir = "journal/daily"

let current_year = (date now | format date "%Y")
let month_dir = (date now | format date "%m-%B")
let filename = (date now | format date "%Y-%m-%d.md")

let path = [$note_dir, $daily_dir, $current_year, $month_dir] | str join "/"
let absolute_file = [$path, $filename] | str join "/" 

# This assures file creation works if the directory is incomplete.
# That would commonly happen at the begining of years and each month.
mkdir $path

# TODO: Replace `touch` with template driven file creation
if not ($absolute_file | path exists) { 
  print "Daily noted didn't exist yet. Creating one now!"
  touch $absolute_file
}

nvim $absolute_file

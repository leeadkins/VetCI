VetCI
-----

VetCI makes it easy to take care of your code pets.  It's a barebones continuous integration system that lets you run commands (usually testing or building) against as many projects as you need. It's heavily inspired by CIJoe, but is designed to be a bit more flexible.

This documentation isn't even close to complete. It will be a mess for a while until version 1.


The Vetfile
-----------

Your project's Vetfile is a crucial piece of the VetCI system. This file describes your system's overall structure to VetCI and explains how tests should be run.  VetCI is very flexible regarding which test framework(s) you choose to use - the only requirement is that your test suite return 0 on success and some other integer on fail.


If you have a single project, you can include a Vetfile in the project root directory (at the same level as your Gemfile for Ruby or your package.json for Node).

Vetfile Options

name            The display name of your project.
path            The path to your project, relative to the Vetfile.
command         The build/test command that should be run on your project.
autoupdate      When set to true, automatically performs a git fetch origin and hard reset on the code prior to running the tests. Defaults to true.
default_branch  Specifies the default branch VetCI should try to work with.
j
================

This repository contains `j`, a utility that helps you jump around
your filesystem. For example, saying

    j foo bar

will match any path in memory that has `foo` in it followed by `bar`. Then
`j` uses the `frecency` algorithm to determine the best match. If one match turns out to be a common root 
of the matches, `j` skips the algorithm and just returns that match.

Installing `j` is as simple as putting this in your shells rc file, and

    source j.bash

it is possible to change the location of the Perl file using the `$_J_LIB`
environment variable.

Inspiration
-----------

Use [z][] if it works correctly on your machine.

[z]: https://github.com/rupa/z

---
For more information, see [the man page](j.1).

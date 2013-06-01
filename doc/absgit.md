## The Problem

You can do this:

    cd /
    svn commit --message blah /some/absolute/path

but you can't do this:

    cd /
    git commit --message blah /some/absolute/path

More generally,
Git requires you to be within the
repository, whereas Subversion does not.

## The solution

A program called `absgit`.
To use it, simply type your desired Git
command, replacing the initial "git" with "absgit".
For example:

    absgit commit --message blah /some/absolute/path

Its logic is simple.
It skips over the Git subcommand and iterates
over the remaining arguments, looking
for the first argument which contains a slash and
names a path inside a Git repository.
If it finds no such argument, it simply delegates to
Git.

On the other hand, if it *does*
find such an argument,
it infers `GIT_DIR` and `GIT_WORK_TREE`,
then invokes `git` with these
variables in its environment.

Also,
any argument which contains a slash and denotes
a path inside the repository is turned into an
absolute path before being passed to Git.
This enables relative paths and symlinks to work.

## Options

`absgit` accepts the `--help` and `--version` options.

## Origin of name

‘abs’ is from ‘absolute’;
the software is commonly used with
absolute pathnames.

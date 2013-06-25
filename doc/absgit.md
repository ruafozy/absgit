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
a path inside the repository is turned into a
canonicalised absolute pathname before being passed to Git.
This enables relative paths and symlinks to work.

## --path

Some Git subcommands,
such as "`git push`",
don't operate on paths, which renders the
above logic useless.
For situations like this,
the "`--path`" option is available.
Its argument is used to determine the values
of
`GIT_DIR` and `GIT_WORK_TREE`.

Here's an example use in context:

    vim /home/me/my_project/my_module.rb
    absgit commit /home/me/my_project/my_module.rb
    absgit --file /home/me/my_project/my_module.rb push

## Options

`absgit` accepts the `--help` and `--version` options.

## Origin of name

‘abs’ is from ‘absolute’;
the software is commonly used with
absolute pathnames.

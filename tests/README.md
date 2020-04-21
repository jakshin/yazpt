Yazpt's tests.

These are halfway between unit and integration tests; each covers a small unit of functionality,
and some of them use mocks, but they mostly call out to the real VCS command-line tools,
and the Git/Subversion/TFVC tests need network access to run successfully.

They utilitize a few pre-existing repos:
* https://github.com/jakshin/yazpt-test
* https://svn.riouxsvn.com/yazpt-svn-test
* https://dev.azure.com/jasonjackson0568/yazpt-tfvc-test

Yazpt's tests.

These are halfway between unit and E2E tests; each covers a small unit of functionality,
and some of them use mocks, but they mostly call out to the real VCS command-line tools,
and the tests covering Git, Subversion and TFVC need network access to run successfully,
because they utilitize pre-existing repos with some test fixtures already set up.

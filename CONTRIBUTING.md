# Contributing

Keep changes small, portable, and evidence-based. Run the targeted regression before
opening a change:

```bash
bash tests/run-targeted-regression.sh
```

Tests must create fixtures at runtime. Versioned fixtures may describe a test case,
but must not contain complete secret-like values, private keys, personal settings,
machine identity, or copied exports. Prefer deliberately assembled synthetic strings
inside the test runner, and assert that scanner output redacts sensitive paths.

Do not add restore, export, push, backup, identity, or credential-management tooling.
This repository is a public reference implementation, not a personal environment
distribution.

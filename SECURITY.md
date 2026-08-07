# Security policy

Do not commit credentials, personal agent state, private keys, tokens, session data,
or machine-specific exports to this repository.

If a secret is exposed, first rotate or revoke it. Then remove it from the affected
files and follow your hosting provider's documented history-cleanup process if the
secret reached Git history. Do not post the secret, a screenshot containing it, or
personal contact details in an issue.

For a potential vulnerability, use GitHub private vulnerability reporting after it is
enabled for the published repository. Until it is available, a public issue may contain
only a generic request for a private contact channel. Do not disclose exploit details,
reproduction steps, impact details, affected paths, credentials, personal data, machine
paths, or private repository links in a public issue.

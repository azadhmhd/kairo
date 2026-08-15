# ADR-0006: Noncommercial Licence

Status: Accepted

Date: 2026-08-15

Amends [ADR-0001](ADR-0001-project-principles.md), principle 1.

## Context

Kairo was published under the MIT licence, which permits anyone to sell the
software or a derivative of it. The author wants the source to stay public and
readable — anyone may read it, run it, fork it, learn from it and contribute
back — but does not want someone else shipping Kairo commercially.

MIT cannot express that. Neither can any OSI-approved licence: the Open Source
Definition, clause 6, forbids restricting the field of endeavour, and
"noncommercial only" is exactly such a restriction. There is no copyleft
licence that helps either; the GPL family permits commercial use by design.

## Decision

Kairo is licensed under **PolyForm Noncommercial 1.0.0**.

Copyright holder: Azad Mohamed (github.com/azadhmhd).

PolyForm Noncommercial was chosen over the alternatives because it is drafted
for software, written in plain language, published as a standard and
recognisable licence rather than a bespoke one, and grants an explicit patent
licence. Creative Commons BY-NC was rejected: Creative Commons itself
recommends against using its licences for software.

## Consequences

**Kairo is source-available, not open source.** This wording matters and is
used consistently: `README`, the repository description and any release notes
must not call Kairo open source, because under the Open Source Definition it
no longer is. GitHub will show the licence as "Other" rather than a recognised
open-source badge, and Kairo cannot be published to pub.dev, Homebrew core or
any distribution channel that requires an OSI licence.

What is unchanged: the repository is public, every line is readable, issues
and pull requests are open, and any noncommercial use — personal, hobby,
academic, charitable, governmental — is permitted without asking.

Contributions are accepted on the understanding that they are licensed to the
project under the same terms. A commercial licence can be granted separately
by the copyright holder, because a single author holds the copyright; that
stops being true the moment substantial contributions arrive from others
without a contributor licence agreement.

The licence covers the software. The character art in `assets/` is the
author's work and is covered by the same terms.

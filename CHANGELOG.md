# Changelog

<!--
Prefix your message with one of the following:

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.
-->

## Unreleased

- [Fixed] Add version restriction to ActiveRecord >= 6.0 and < 7.0, as Rails 7
  now supports Postgres enums out of the box.

## v0.4.0 - 2021-09-16

- [Changed] Sort enums by name.
- [Removed] Support for Rails 5.2

## v0.3.0 - 2019-11-26

- [Added] Support for Rails 6.

## v0.2.3 - 2019-03-12

- [Fixed] Don't try to recreate a type that already exists.

## v0.2.2 - 2019-03-12

- [Fixed] Schema dumping.

## v0.2.1 - 2019-03-11

- [Added] Define `enum` type so schema dumper can work appropriately.

## v0.2.0 - 2019-03-10

- [Added] Add command recorder reversing.

## v0.1.0 - 2019-03-10

- Initial release.

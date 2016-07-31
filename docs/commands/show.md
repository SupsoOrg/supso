# The `show` command

The `show` command shows a list of projects used by your project, and whether you have tokens for those projects.

Usage:

```
$ supso show
3 projects using Supported Source.
dataduck-etl
  Source: add (ruby)
  Valid: Yes
js_supso_test
  Source: npm
  Valid: No
  Reason: Missing client token. Run `supso update` to update the token.
yet-another-ruby-project
  Source: add (ruby)
  Valid: No
  Reason: Missing client token. Run `supso update` to update the token.
```

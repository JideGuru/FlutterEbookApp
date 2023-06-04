# Readium JS (Kotlin)

A set of JavaScript files used by the Kotlin EPUB navigator.

This folder starts with an underscore to prevent Gradle from embedding it as an asset.

## Scripts

Run `npm install`, then use one of the following:

* `yarn run bundle` Rebuild the assets after any changes in the `src/` folder.
* `yarn run lint` Check code quality.
* `yarn run checkformat` Check if there's any formatting issues.
* `yarn run format` Automatically format JavaScript sources.

In case `bundle` does not work with recent NodeJS versions (17+), a workaround is:
`export NODE_OPTIONS=--openssl-legacy-provider`

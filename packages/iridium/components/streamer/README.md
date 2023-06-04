# mno_streamer

Streamer API and multiple file parsers (PDF, CBZ, Epub) for Dart. This code is inspired by [Readium 2](https://readium.org/technical/r2-toc/) Streamer ([Kotlin](https://github.com/readium/r2-streamer-kotlin), [Swift](https://github.com/readium/r2-streamer-kotlin), [Swift](https://github.com/readium/r2-streamer-swift) and [NodeJS/TypeScript](https://github.com/readium/r2-streamer-js)).
In contrast with Readium 2 Streamer, the server part is separate, in [mno_server_dart](https://github.com/Mantano/mno_server_dart)

## Epub parser

Epub parser for Dart.

## PDF parser

This package defines API for PDF support. However it does not provide an implementation. If the ```Streamer``` is not created with an implementation of ```PdfDocumentFactory```, an exception is raised when attempting to parse a PDF file.

## CBZ parser

CBZ parser for Dart.

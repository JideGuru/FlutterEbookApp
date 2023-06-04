# mno_lcp_dart

## Flutter LCP implementation

This package provides a DART LCP layer. 

Important: The implementer must ask [Edrlab](https://edrlab.org) how to get `liblcp` native libs.

For Android, it should look like in build.gradle:
```
compile files('../lcp-aar/liblcp.aar')
compile files('../lcp-aar/liblcp-flutter.aar')
```

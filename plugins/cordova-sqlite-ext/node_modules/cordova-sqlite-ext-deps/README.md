# cordova-sqlite-ext dependencies

AUTHOR: Christopher J. Brody

LICENSE: [Unlicense (unlicense.org)](http://unlicense.org/) (public domain)

Contains source and object code built from:
- SQLite3 (public domain)
- [litehelpers / Android-sqlite-native-driver-regexp-pcre](https://github.com/litehelpers/Android-sqlite-native-driver-regexp-pcre) (Unlicense, public domain)
- [liteglue / Android-sqlite-connector](https://github.com/liteglue/Android-sqlite-connector) (Unlicense, public domain)
- sqlite3-pcre (public domain) from git.altlinux.org/people/at/packages/?p=sqlite3-pcre.git (thanks to [ralight / sqlite3-pcre](https://github.com/ralight/sqlite3-pcre) for the link)
- PCRE `8.37` (BSD 3-clause)

This project provides the following dependencies needed by [litehelpers / cordova-sqlite-ext](https://github.com/litehelpers/cordova-sqlite-ext):
- `sqlite3.h`, `sqlite3.c` - SQLite `3.8.10.2` amalgamation needed to build iOS and Windows versions
- `libs` - [liteglue / Android-sqlite-connector](https://github.com/liteglue/Android-sqlite-connector) JAR and [litehelpers / Android-sqlite-native-driver-regexp-pcre](https://github.com/litehelpers/Android-sqlite-native-driver-regexp-pcre) NDK libraries built with SQLite `3.8.10.2` amalgamation and PCRE `8.31`

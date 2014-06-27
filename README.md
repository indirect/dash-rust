# [Dash](http://kapeli.com/dash) docset for [Rust](http://rust-lang.org)

## Installation

Subscribe to the [Docset feed (redirects to a `dash-feed://`)](http://docset.crystae.net/feeds/Rust_Nightly.dash-feed). New versions are built with the latest nightly of Rust and published to the feed daily. If you want to generate the docset yourself, follow the steps in "Usage" below.

## Usage

```bash
$ bundle install
$ rake
$ open Rust.docset
```

To download the documentation for the latest Rust nightly and build a
fresh docset from that:

```bash
$ bundle install
$ rake nightly
$ open Rust.docset
```

### License

MIT License, copyright 2014 by André Arko

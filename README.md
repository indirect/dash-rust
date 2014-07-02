# [Dash](http://kapeli.com/dash) docset for [Rust](http://rust-lang.org)

## Installation

Subscribe to the [Docset feed (redirects to a `dash-feed://`)](http://docset.crystae.net/feeds/Rust_Nightly.dash-feed). New versions are built with the latest nightly of Rust and published to the feed daily. If you want to generate the docset yourself, follow the steps in "Usage" below.

## Usage

To download the documentation for the latest Rust nightly and build a
fresh Rust docset from that:

```bash
$ bundle install
$ rake nightly
$ open Rust.docset
```

To generate a docset for your own crate(s), see `example.sh`. N.B. if
you run `rustdoc` on multiple crates with the sample output directory,
a docset generated from that directory will include all of those
crates.

### License

MIT License, copyright 2014 by André Arko

require './lib/docset_index'
require './lib/docset_theme'
require './lib/docset_addrefs'

task :default => %w(docset)

desc "Generate a .docset for Rust"
task :docset => [
  "Rust.docset/icon.png",
  "Rust.docset/Contents/Info.plist",
  "Rust.docset/Contents/Resources/Documents",
  "docset:index",
  "docset:theme"
]

file "rust-nightly-x86_64-unknown-linux-gnu.tar.gz" do
  sh "curl -O http://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz"
end

file "rust-nightly-x86_64-unknown-linux-gnu" => "rust-nightly-x86_64-unknown-linux-gnu.tar.gz" do
  sh "tar -xzf rust-nightly-x86_64-unknown-linux-gnu.tar.gz"
end

task :nightly_prep do
  rm "rust-nightly-x86_64-unknown-linux-gnu.tar.gz", force: true
  rm_rf "rust-nightly-x86_64-unknown-linux-gnu"
  ENV["RUST_DOCS"] = "rust-nightly-x86_64-unknown-linux-gnu"
end

desc "Download latest nightly docs and build a fresh docset"
task :nightly => [:clean, :nightly_prep, "rust-nightly-x86_64-unknown-linux-gnu", :docset]

directory "Rust.docset/Contents/Resources"

file "Rust.docset/Contents/Info.plist" => [
  "Rust.docset/Contents/Resources"
] do
  cp "Info.plist", "Rust.docset/Contents/"
end

file "Rust.docset/icon.png" => [
  "Rust.docset/Contents/Resources"
] do
  cp "icon.png", "Rust.docset/"
end

file "Rust.docset/Contents/Resources/Documents" => [
  "Rust.docset/Contents/Resources"
] do
  local_docs = [
    File.expand_path("~/Desktop/rust-nightly-x86_64-unknown-linux-gnu/doc"),
    File.expand_path("~/src/mozilla/rust/doc"),
    ENV['RUST_DOCS']
  ].find{|path| path && File.exist?(path) }

  local_docs ||= begin
    puts "Enter the path to the local rust docs"
    gets.chomp
  end

  if !File.exist?(local_docs + "/index.html")
    if File.exist?(local_docs + "/doc/index.html")
      local_docs += "/doc"
    else
      puts "Path " + local_docs + " is not a rust doc directory!"
      exit 1
    end
  end

  cp_r local_docs, "Rust.docset/Contents/Resources/Documents"
  puts "Generating TOC"
  FileList["Rust.docset/Contents/Resources/Documents/**/*.html"].each do |f|
    DocsetAddrefs.new(f, f).add_refs
  end
end

file "Rust.docset/Contents/Resources/Documents/main.css.orig" => [
  "Rust.docset/Contents/Resources/Documents"
] do
  doc_path = "Rust.docset/Contents/Resources/Documents"
  stylesheet = File.join(doc_path, "main.css")
  cp stylesheet, "#{stylesheet}.orig"

  DocsetTheme.new(stylesheet).save
end

file "Rust.docset/Contents/Resources/docSet.dsidx" => [
  "Rust.docset/Contents/Resources"
] do
  DocsetIndex.new("Rust.docset/Contents/Resources/Documents").save
end

namespace :docset do
  desc "Generate a Dash index from the docs"
  task :index => [
    "Rust.docset/Contents/Resources/Documents",
    "Rust.docset/Contents/Resources/docSet.dsidx"
  ]

  task :reindex do
    rm_rf "Rust.docset/Contents/Resources/docSet.dsidx"
    Rake::Task["docset:index"].invoke
  end

  desc "Apply some Dash-friendly CSS to the docs stylesheet"
  task :theme => [
    "Rust.docset/Contents/Resources/Documents/main.css.orig"
  ]

  task :retheme do
    doc_path = "Rust.docset/Contents/Resources/Documents"
    cp File.join(doc_path, "main.css.orig"), File.join(doc_path, "main.css")
    rm File.join(doc_path, "main.css.orig")
    Rake::Task["docset:theme"].invoke
  end
end

desc "Remove docset"
task :clean do
  rm_rf "Rust.docset"
end

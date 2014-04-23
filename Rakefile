require 'rubygems'
require 'bundler/setup'
require './lib/docset_index'
require './lib/docset_theme'

task :default => %w(docset)

desc "Generate a .docset for Rust"
task :docset => [
  "Rust.docset/icon.png",
  "Rust.docset/Contents/Info.plist",
  "Rust.docset/Contents/Resources/Documents",
  "docset:index",
  "docset:theme"
]

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

  cp_r local_docs, "Rust.docset/Contents/Resources/Documents"
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

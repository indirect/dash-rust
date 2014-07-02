require 'plist'

require './lib/docset_index'
require './lib/docset_theme'
require './lib/docset_addrefs'

def local_docs
  ENV['DOCS_PATH']
end

def docset_name
  ENV['DOCSET_NAME']
end

def docset_group
  ENV['DOCSET_GROUP'] || "rustlibs"
end

def docset_id
  ENV['DOCSET_ID']
end

def docset_dir
  "#{docset_name}.docset"
end

def docset_guides
  ENV['DOCSET_GUIDES'] == '1'
end

desc "Download latest nightly docs and build a fresh docset"
task :nightly do
  sh "./nightly.sh"
end

task :default => %w(docset)

desc "Generate a .docset for Rust"
task :docset => [
  "check_env",
  "#{docset_dir}/icon.png",
  "#{docset_dir}/Contents/Info.plist",
  "#{docset_dir}/Contents/Resources/Documents",
  "docset:index",
  "docset:theme"
]

directory "#{docset_dir}/Contents/Resources"

file "#{docset_dir}/Contents/Info.plist" => [
  "#{docset_dir}/Contents/Resources"
] do
  ob = {
    "CFBundleIdentifier" => docset_id,
    "CFBundleName" => docset_name,
    "DocSetPlatformFamily" => docset_group,
    "isDashDocset" => true,
    "dashIndexFilePath" => "index.html",
    "DashDocSetFamily" => "dashtoc"
  }
  File.open("#{docset_dir}/Contents/Info.plist", "w") do |file|
    file.write(Plist::Emit.dump(ob))
  end
end

file "#{docset_dir}/icon.png" => [
  "#{docset_dir}/Contents/Resources"
] do
  cp "icon.png", "#{docset_dir}/"
end

file "#{docset_dir}/Contents/Resources/Documents" => [
  "#{docset_dir}/Contents/Resources"
] do
  if !File.exist?(local_docs + "/search-index.js")
    puts "Path " + local_docs + " is not a rustdoc directory!"
    exit 1
  end

  cp_r local_docs, "#{docset_dir}/Contents/Resources/Documents"
  puts "Generating TOC"
  FileList["#{docset_dir}/Contents/Resources/Documents/**/*.html"].each do |f|
    DocsetAddrefs.new(f, f).add_refs
  end
end

file "#{docset_dir}/Contents/Resources/Documents/main.css.orig" => [
  "#{docset_dir}/Contents/Resources/Documents"
] do
  doc_path = "#{docset_dir}/Contents/Resources/Documents"
  stylesheet = File.join(doc_path, "main.css")
  cp stylesheet, "#{stylesheet}.orig"

  DocsetTheme.new(stylesheet).save
end

file "#{docset_dir}/Contents/Resources/docSet.dsidx" => [
  "#{docset_dir}/Contents/Resources"
] do
  DocsetIndex.new("#{docset_dir}/Contents/Resources/Documents", docset_guides).save
end

desc "Perform some sanity checks on the environment variables."
task :check_env => [
  "check_env:local_docs",
  "check_env:docset_name",
  "check_env:docset_id",
]

namespace :check_env do
  task :local_docs do
    if local_docs.nil?
      puts "DOCS_PATH environment variable not set, or path doesn't exist"
      exit 1
    end

    unless File.exist?(local_docs)
      puts "DOCS_PATH '#{local_docs}' does not exist"
      exit 1
    end
  end

  task :docset_name do
    if docset_name.nil?
      puts "DOCSET_NAME environment variable not set"
      exit 1
    end
  end

  task :docset_id do
    if docset_id.nil?
      puts "DOCSET_ID environment variable not set"
      exit 1
    end
  end
end

namespace :docset do
  desc "Generate a Dash index from the docs"
  task :index => [
    "#{docset_dir}/Contents/Resources/Documents",
    "#{docset_dir}/Contents/Resources/docSet.dsidx"
  ]

  task :reindex do
    rm_rf "#{docset_dir}/Contents/Resources/docSet.dsidx"
    Rake::Task["docset:index"].invoke
  end

  desc "Apply some Dash-friendly CSS to the docs stylesheet"
  task :theme => [
    "#{docset_dir}/Contents/Resources/Documents/main.css.orig"
  ]

  task :retheme do
    doc_path = "#{docset_dir}/Contents/Resources/Documents"
    cp File.join(doc_path, "main.css.orig"), File.join(doc_path, "main.css")
    rm File.join(doc_path, "main.css.orig")
    Rake::Task["docset:theme"].invoke
  end
end

desc "Remove docset"
task :clean => "check_env:docset_name" do
  rm_rf docset_dir
end

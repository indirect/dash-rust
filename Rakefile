require './lib/index'

task :default => %w(docset)

desc "Generate a .docset for Rust"
task :docset => [
  "Rust.docset/icon.png",
  "Rust.docset/Contents/Info.plist",
  "Rust.docset/Contents/Resources/Documents",
  "docset:index"
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
    File.expand_path("~/src/mozilla/rust/doc"),
    ENV['RUST_DOCS']
  ].find{|path| path && File.exist?(path) }

  local_docs ||= begin
    puts "Enter the path to the local rust docs"
    gets.chomp
  end

  cp_r local_docs, "Rust.docset/Contents/Resources/Documents"
end

file "Rust.docset/Contents/Resources/docSet.dsidx" => [
  "Rust.docset/Contents/Resources"
] do
  Index.execute "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, " \
    "name TEXT, type TEXT, path TEXT);",
    "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"
end

namespace :docset do
  desc "Generate a Dash index from the docs"
  task :index => [
    "Rust.docset/Contents/Resources/Documents",
    "Rust.docset/Contents/Resources/docSet.dsidx"
  ] do
    require 'nokogiri'
    require 'json'

    docsdir = "Rust.docset/Contents/Resources/Documents"

    # Parse and index guides from the docs root
    rustdoc = Nokogiri::HTML(File.read("#{docsdir}/index.html"))
    [
      "body > ul > li",
      "section#guides li",
      "section#tooling li",
      "section#faq li",
    ].each do |selector|
      rustdoc.css(selector).each do |item|
        link = item.css("a").first
        Index.add link.text, "Guide", link.attr("href")
      end
    end

    DASH_TYPE = {
      "enum" => "Enum",
      "ffi" => "Function",
      "fn" => "Function",
      "method" => "Method",
      "mod" => "Module",
      "static" => "Constant",
      "struct" => "Class",
      "structfield" => "Attribute",
      "trait" => "Protocol",
      "tymethod" => "Method",
      "typedef" => "Type",
      "variant" => "Option",
   }

    # Parse and index everything that can be searched for
    Dir["#{docsdir}/**/search-index.js"].each do |jsfile|
      puts "Indexing #{jsfile.split("/")[-2]}..."

      items, paths = File.read(jsfile).
        scan(/(?:searchIndex|allPaths) \= (.*?)(?:;var|;$)/).
        flatten.
        map{|js| js.gsub("},{", "},\n{") }.
        map{|js| js.gsub(/\:'(.*?)'/m, ':"\1"') }.
        map{|js| js.gsub(/'(.*?)'\:/, '"\1":') }.
        map{|js| js.gsub(/([{,])(\w*)\:/, '\1"\2":') }.
        map{|json| JSON.parse(json) }


      items.each do |i|
        if i["parent"]
          next if paths[i["parent"]].nil?
          path = i["path"] + "/"
          path << paths[i["parent"]].values.join(".") << ".html"
          path << "#" << [i["ty"], i["name"]].join(".")
        else
          if i["name"].empty?
            i["name"] = i["path"]
            path = i["path"] + "/index.html"
          elsif i["ty"] == "mod"
            path = i["path"] + "/" + i["name"] + "/index.html"
          else
            path = i["path"] + "/" + [i["ty"], i["name"]].join(".") + ".html"
          end
        end

        if i["ty"] == "fn"
          name = [i["path"], i["name"]].join("::")
        else
          name = i["name"]
        end

        Index.add name,
          DASH_TYPE[i["ty"]],
          path.gsub("::", "/")
      end
    end

  end

  task :reindex do
    rm_rf "Rust.docset/Contents/Resources/docSet.dsidx"
    Rake::Task["docset:index"].invoke
  end
end

desc "Remove docset"
task :clean do
  rm_rf "Rust.docset"
end

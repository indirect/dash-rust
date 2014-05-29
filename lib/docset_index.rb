class DocsetIndex
  DASH_TYPE = {
    "ffi" => "Function",
    "ffs" => "Constant",
    "fn" => "Function",
    "method" => "Method",
    "mod" => "Module",
    "static" => "Constant",
    "struct" => "_Struct",
    "structfield" => "Field",
    "trait" => "Trait",
    "tymethod" => "Method",
    "type" => "Type",
    "variant" => "Variant",
    "macro" => "Macro"
  }

  ITEM_TYPE = {
    0 => "mod",
    1 => "struct",
    2 => "type",
    3 => "fn",
    4 => "type",
    5 => "static",
    6 => "trait",
    7 => "impl",
    8 => "viewitem",
    9 => "tymethod",
    10 => "method",
    11 => "structfield",
    12 => "variant",
    13 => "ffi",
    14 => "ffs",
    15 => "macro"
  }

  def initialize(dir)
    @dir = dir
    @debug = true if ENV['DEBUG']
  end

  def save
    create_db
    index_docs_index_page
    index_docs_search_indexes
  end

  def create_db
    execute "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, " \
      "name TEXT, type TEXT, path TEXT);",
      "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"
  end

  def index_docs_index_page
    require 'nokogiri'
    # Parse and index guides from the docs root
    rustdoc = Nokogiri::HTML(File.read("#{@dir}/index.html"))
    [
      "#guides + ul li",
      "#tooling + ul li",
      "#faqs + ul li",
    ].each do |selector|
      rustdoc.css(selector).each do |item|
        link = item.css("a").first
        add link.text, "Guide", link.attr("href")
      end
    end
  end

  def index_docs_search_indexes
    require 'execjs'

    jsfile = File.join(@dir, "search-index.js")

    source = File.open(jsfile, "r:UTF-8", &:read)
    context = ExecJS.compile(source + ";function initSearch() {}")
    crates = context.eval("searchIndex")

    crates.keys.each do |crate_key|
      puts "Indexing crate #{crate_key}..."
      crate = crates[crate_key]
      items, paths = crate.values_at("items", "paths")

      paths = paths.map do |p|
        {
          "ty" => ITEM_TYPE[p[0]],
          "name" => p[1]
        }
      end

      # rustdoc changed to use an array for items here:
      #   https://github.com/mozilla/rust/commit/f6854ab46c1303cfee508a4537e235166cd6cc3e
      # and omit repeated paths here:
      #   https://github.com/mozilla/rust/commit/8f5d71cf71849bea25f87836cec1b06b476baf37
      last_path = ""
      items = items.map do |i|
        path = if i[2].empty? then last_path else i[2] end
        row = {
          "ty" => ITEM_TYPE[i[0]],
          "name" => i[1],
          "path" => path,
          "desc" => i[3], # unused
          "parent" => i[4]
        }
        last_path = path
        row
      end

      items.each do |i|
        parent = nil

        if i["parent"]
          parent = paths[i["parent"]]
          next if parent.nil?

          path = i["path"] + "/"
          path << parent["ty"] << "." << parent["name"] << ".html"
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

        name = if parent.nil?
                 [i["path"], i["name"]].join("::")
               else
                 [i["path"], parent["name"], i["name"]].compact.join("::")
               end

        add name, DASH_TYPE[i["ty"]], path.gsub("::", "/")
      end
    end
  end

private

  def dsidx_path
    File.expand_path("../docSet.dsidx", @dir)
  end

  def execute(*cmd)
    IO.popen("sqlite3 #{dsidx_path}", "w+") do |sql|
      cmd.each{|l| sql << l }
    end
  end

  def add(name, type, path)
    p [name, type, path] if @debug

    if type.nil?
      puts "UNKNOWN TYPE for #{name} (#{path})"
    else
      # Sqlite3 single quote escape is two single quotes
      [name, type, path].each{|arg| arg.to_s.gsub!("'", "''") }
      execute("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{type}', '#{path}');")
    end
  end

end

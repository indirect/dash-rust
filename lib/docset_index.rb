class DocsetIndex
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
    "macro" => "Macro"
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
      "body > ul > li",
      "section#guides li",
      "section#tooling li",
      "section#faq li",
    ].each do |selector|
      rustdoc.css(selector).each do |item|
        link = item.css("a").first
        add link.text, "Guide", link.attr("href")
      end
    end
  end

  def index_docs_search_indexes
    require 'json'
    # Parse and index everything that can be searched for
    Dir["#{@dir}/**/search-index.js"].each do |jsfile|
      puts "Indexing #{jsfile.split("/")[-2]}..."

      items, paths = File.open(jsfile, "r:UTF-8", &:read).
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
      puts "UNKNOWN TYPE #{type}"
    else
      # Sqlite3 single quote escape is two single quotes
      [name, type, path].each{|arg| arg.to_s.gsub!("'", "''") }
      execute("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{type}', '#{path}');")
    end
  end

end
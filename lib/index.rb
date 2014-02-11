class Index
  def self.execute(*cmd)
    IO.popen('sqlite3 Rust.docset/Contents/Resources/docSet.dsidx', 'w+') do |sql|
      cmd.each{|l| sql << l }
    end
  end

  def self.add(name, type, path)
    # Sqlite3 single quote escape is two single quotes
    [name, type, path].each{|arg| arg.gsub!("'", "''") }
    p [name, type, path] if ENV['DEBUG']
    execute("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{type}', '#{path}');")
  end
end
class DocsetFetchAssets
  def initialize(stylesheet, dest_path)
    @stylesheet = stylesheet
    @dest_path = dest_path
  end

  def save
    puts "Fetching remote assets..."
    urls = find_remote_assets
    urls.each { |u| download_asset(u) }
  end

  def find_remote_assets
    open(@stylesheet, "r:UTF-8") do |f|
      f.each_line.reduce(Set.new) do |found, line|
        match = line.match(/url\("(http:\/\/.*)"\)/)
        if match.nil?
          found
        else
          found + [match[1]]
        end
      end
    end
  end

  def download_asset(url_str)
    require 'uri'
    require 'open-uri'

    url = URI.parse(url_str)
    dest_path = File.join(@dest_path, url.path)
    FileUtils.mkdir_p(File.dirname(dest_path))

    puts "Fetching #{url.path} to #{@dest_path}"

    open(url) do |src|
      File.open(dest_path, "wb") do |dest|
        dest.write src.read
      end
    end
  end
end

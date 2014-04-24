class DocsetReplaceAssets
  def initialize(stylesheet)
    @stylesheet = stylesheet
  end

  def save
    replace_remote_assets
  end

  def replace_remote_assets
    puts "opening #{@stylesheet}"
    open(@stylesheet, "r+:UTF-8") do |f|
      lines = f.each_line.map do |line|
        line.gsub(/url\("(http:\/\/.*)"\)/) do |x|
          url = URI.parse($1)
          path = File.join("_assets", url.path)
          replace = %{url("#{path}")}
          puts "Replacing #{x} with #{replace}"
          replace
        end
      end

      f.rewind
      len = f.write(lines.join(""))
      f.truncate(len)
    end
  end
end

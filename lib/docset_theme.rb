class DocsetTheme
  def initialize(stylesheet)
    @stylesheet = stylesheet
    @debug = true if ENV['DEBUG']
  end

  def save
    append_styles
  end

  protected

  def append_styles
    puts "Applying Docset style overrides..."
    open(@stylesheet, "a:UTF-8") do |f|
      f.write <<-CSS


/* Dash DocSet overrides */

.sidebar, .sub { display: none; }
.content { margin-left: 0; }
CSS
    end
  end
end

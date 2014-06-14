require 'open-uri'
require 'nokogiri'

class DocsetAddrefs
  def initialize(fin, fout)
    @fin = fin
    @fout = fout

    @d = Nokogiri::HTML(File.read(@fin))
  end

  def add_refs
    @d.css('#main .method').each do |n|
      name = URI::encode(n['id'].gsub(/^(ty)?method\./, ''))
      append_node n, 'Method', name
    end
    @d.css('#main .impl .trait').each do |n|
      name = URI::encode(n.content)
      append_node n, 'Trait', name
    end
    @d.css('#main td .trait').each do |n|
      name = URI::encode(n.content)
      append_node n, 'Trait', name
    end
    @d.css('#main td .mod').each do |n|
      name = URI::encode(n.content)
      append_node n, 'Module', name
    end
    @d.css('#main td .struct').each do |n|
      name = URI::encode(n.content)
      append_node n, 'Struct', name
    end
    @d.css('#main td .fn').each do |n|
      name = URI::encode(n.content)
      append_node n, 'Function', name
    end
    open(@fout, 'w') do |f|
      f.write(@d.serialize)
    end
  end

  def append_node(n, ty, nm)
    a = Nokogiri::XML::Node.new('a', @d)
    a['name'] = "//apple_ref/cpp/#{ty}/#{nm}"
    a['class'] = 'dashAnchor'
    n.previous = a
  end
end

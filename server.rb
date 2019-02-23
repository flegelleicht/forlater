require 'sinatra/base'
require 'open-uri'
require 'yaml/store'

class Server < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end
  
  before do
    @store = YAML::Store.new('db.yml')
    @store.transaction do
      @store.abort if @store[:urls]
      @store[:urls] = []
    end
  end

  get '/s/flgl/?' do
    content_type :html
    "<!DOCTYPE html><html><head><title>urls</title></head><body><h3>#{urls.count}</h3><ul>#{urls.reduce(""){|a,u| "<li><a href=\"#{u[:url]}\">#{u[:title]}</a>#{a}"}}</ul></html>"
  end

  get '/a/flgl/*' do
    # Extract  url
    url = request.url.partition('/a/flgl/').last
    url = url.sub(/^http(s?):\/([^\/])/, 'http\1://\2')

    # Prepare and add entry
    entry = { title: get_title(url), url: url }
    add(entry)
    
    # Deliver page that redirects to url after some seconds
    content_type :html
    "<!DOCTYPE html><html><head><title>urls</title><meta http-equiv=\"Refresh\" content=\"3; url=#{url}\" /></head><body><h3>#{urls.count}</h3><ul>#{urls.reduce(""){|a,u| "<li><a href=\"#{u[:url]}\">#{u[:title]}</a>#{a}"}}</ul></html>"
  end 

  private

  def get_title(url)
    scan = open(url).read.scan(/<title>(.*?)<\/title>/).first.first
  rescue OpenURI::HTTPError, NoMethodError
    "No Title (possible 404)" 
  end

  def urls
    @store.transaction { @store[:urls] }
  end

  def add(entry)
    @store.transaction do
      urls = @store[:urls]
      urls << entry unless urls.map{|u| u['url']}.include? entry[:url]
      @store[:urls] = urls
    end
  end
end


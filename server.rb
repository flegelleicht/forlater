require 'sinatra/base'
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

  get '/s/flgl' do
    content_type :html
    "<!DOCTYPE html><html><head><title>urls</title></head><body><h3>#{urls.count}</h3><ul>#{urls.reduce(""){|a,u| "<li><a href=\"#{u}\">#{u}</a>#{a}"}}</ul></html>"
  end

  get '/a/flgl/*' do
    # Put url in store
    url = request.url.partition('/a/flgl/').last
    add(url)
    
    # Deliver page that redirects to url after some seconds
    content_type :html
    "<!DOCTYPE html><html><head><title>urls</title><meta http-equiv=\"Refresh\" content=\"3; url=#{url}\" /></head><body><h3>#{urls.count}</h3><ul>#{urls.reduce(""){|a,u| "<li><a href=\"#{u}\">#{u}</a>#{a}"}}</ul></html>"
  end 

  private

  def urls
    @store.transaction { @store[:urls] }
  end

  def add(url)
    @store.transaction do
      urls = @store[:urls]
      urls << url unless urls.include? url
      @store[:urls] = urls
    end
  end
end


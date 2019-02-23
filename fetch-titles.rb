require 'yaml/store'
require 'open-uri'
require 'pp'

DEFAULT_TITLE = "No Title (possible 404)"

def get_title(url)
  scan = open(url).read.scan(/<title>(.*?)<\/title>/).first.first
  p scan
  scan
rescue OpenURI::HTTPError, NoMethodError
  DEFAULT_TITLE
end

store = YAML::Store.new('db.yml')
urls = store.transaction { store[:urls] }
newrls = []
urls.each do |u| 
  if u[:title] == DEFAULT_TITLE
    t = {}; 
    t[:title] = get_title(u[:url]); 
    t[:url] = u[:url];
    newrls << t
  else
    newrls << u
  end
end
pp newrls
store.transaction { store[:urls] = newrls } 


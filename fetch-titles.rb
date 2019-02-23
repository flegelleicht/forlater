require 'yaml/store'
require 'open-uri'
require 'pp'

def get_title(url)
  scan = open(url).read.scan(/<title>(.*?)<\/title>/).first.first
  p scan
  scan
rescue OpenURI::HTTPError, NoMethodError
  "No Title (possible 404)" 
end

store = YAML::Store.new('db.yml')
urls = store.transaction { store[:urls] }
newrls = []
urls.each do |u| 
  if u[:title] == "No Title (possible 404)"
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


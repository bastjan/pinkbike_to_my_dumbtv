require 'rss'
require 'open-uri'
require 'sinatra'
require 'nokogiri'

set :bind, '0.0.0.0'

def feed_to_linklist
	url = 'http://www.pinkbike.com/pinkbike_xml_feed.php'

	open(url) do |rss|
		feed = RSS::Parser.parse(rss)

		feed.items.map do |item|
			a item.title, href: "/item/" + item.link.gsub(%r{https?://}, "")
		end
	end
end

def a(title, href: "#")
	"<a href='#{href}'>#{title}</a>"
end

def get_video_url_from_page(page)
	url = "http://" + params[:captures].first

	open(url) do |page|
		page = Nokogiri::HTML(page)
		video_link = page.css("video source[res='1080']")[0]['src']

		return video_link
	end
end

get '/' do
	feed_to_linklist.join("<br>")
end

get /\/item\/(.+)/ do
	url = "http://" + params[:captures].first

	erb :item, locals: {
		video_url: get_video_url_from_page(url)
	}
end

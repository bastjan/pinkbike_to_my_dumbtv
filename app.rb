require 'rss'
require 'open-uri'
require 'sinatra'
require 'nokogiri'

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

def redirect_to_video_file(page)
	url = "http://" + params[:captures].first

	open(url) do |page|
		page = Nokogiri::HTML(page)
		video_link = page.css("video source[res='1080']")[0]['src']

		redirect video_link
	end
rescue
	"Not a pinkbike video"
end

get '/' do
	feed_to_linklist.join("<br>")
end

get /\/item\/(.+)/ do
	url = "http://" + params[:captures].first

	redirect_to_video_file(url)
end

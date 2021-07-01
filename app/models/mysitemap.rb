require 'wayback_archiver'
require 'sitemap-parser'
require 'open-uri'
require 'nokogiri'

siteMapUrl = ARGV[0]
if !siteMapUrl.nil?
  Nokogiri::XML(File.open('test1.xml')).xpath("//url/loc").each do |node|
	siteMapLink = node.content
	subSiteMapLink = SitemapParser.new siteMapLink
	arraySubSiteMapLink = subSiteMapLink.to_a
	(0..arraySubSiteMapLink.length-1).each do |j|
  	WaybackArchiver.archive(arraySubSiteMapLink[j], :url)
	end
  end
end
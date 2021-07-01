MysitemapController < ApplicationController
  layout nil
  def index
	headers['Content-Type'] = 'application/xml'
	respond_to do |format|
  	format.xml {@articles = Article.all}
	end
  end
end
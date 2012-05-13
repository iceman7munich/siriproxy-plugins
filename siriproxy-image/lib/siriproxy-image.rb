# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::Image < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
	end
  
	listen_for /image (.*)/i do |query|

		query = query.sub('d\'','').sub('l\'','').sub('le ','').sub('du ','').sub('de ','').sub('pour ','')
		url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{URI.encode(query)}"

		jsonString = Net::HTTP.get(URI.parse(url))
		json = JSON.parse(jsonString)

		if json["responseData"]['results'] != nil
			image = json['responseData']['results'][0]['unescapedUrl']
			
			object = SiriAddViews.new
			object.make_root(last_ref_id)
			answer = SiriAnswer.new("Image :", [
				SiriAnswerLine.new("logo", "#{image}")
			])
			object.views << SiriAnswerSnippet.new([answer])
			send_object object

		else
			say "Je n'ai trouvé aucune image"
		end

		request_completed
	end
	
end

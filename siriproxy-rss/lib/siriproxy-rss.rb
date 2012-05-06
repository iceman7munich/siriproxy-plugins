# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::RSS < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
	end

	class RSS
		include HTTParty
		format :xml
		
		def initialize(plugin, titre, uri, flux)
			rss = RSS.get(flux)
			plugin.say "Voilà les derniers articles parus sur #{titre} :"
			answers = []
			if rss != nil
				rss["rss"]["channel"]["item"].each do |item|
					title = item["title"]
					image = item["description"][/.*<img.*src="([^"]*)"/,1]
					description = item["description"].gsub(%r{</?[^>]+?>}, '')
					if image != nil
						answers.push(SiriAnswer.new(title, [SiriAnswerLine.new("logo",image),SiriAnswerLine.new("#{description}")]))
					elsif
						answers.push(SiriAnswer.new(title, [SiriAnswerLine.new("#{description}")]))
					end
				end

				view = SiriAddViews.new
				view.make_root(plugin.last_ref_id)
				view.views << SiriAnswerSnippet.new(answers)
				view.views << SiriButton.new("Aller sur le site", [OpenLink.new(uri.gsub("//",""))])
				plugin.send_object view
			end
			plugin.request_completed
		end
	end
	
	class OpenLink < SiriObject
	  def initialize(ref="")
		super("OpenLink", "com.apple.ace.assistant")
		self.ref = ref
	  end
	end
	add_property_to_class(OpenLink, :ref)

	listen_for /iphone soft/i do
		title = "iPhoneSoft.fr"
		uri = "http://iphonesoft.fr"
		flux = "http://fulltextrssfeed.com/feeds.feedburner.com/IphoneSoft"
		RSS.new(self,title,uri,flux)
	end
	
	listen_for /iphone utilitaire/i do
		title = "iPhoneTweak.fr"
		uri = "http://iphonetweak.fr"
		flux = "http://fulltextrssfeed.com/feeds.feedburner.com/Iphonetweak"
		RSS.new(self,title,uri,flux)
	end	
	
	listen_for /pc i(n|m)pact/i do |ph|
		title = "PC INpact"
		uri = "http://www.pcinpact.com"
		flux = "http://fulltextrssfeed.com/www.pcinpact.com/rss/news.xml"
		RSS.new(self,title,uri,flux)
	end
	
end

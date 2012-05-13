# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::Actualite < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
	end
	
	filter "SetRequestOrigin", direction: :from_iphone do |object|
		if object["properties"]["status"] != "Denied"
			@latitude = object["properties"]["latitude"]
			@longitude = object["properties"]["longitude"]
		else
			@latitude = nil
			@longitude = nil
		end
	end
	
	class OpenLink < SiriObject
	  def initialize(ref="")
		super("OpenLink", "com.apple.ace.assistant")
		self.ref = ref
	  end
	end
	add_property_to_class(OpenLink, :ref)

	class RSS
		include HTTParty
		format :xml
		
		def initialize(plugin, titre, uri, flux)
			rss = RSS.get(flux)
			plugin.say "Voici les dernières infos du jour :"
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
				view.views << SiriButton.new("Ouvrir Google News", [OpenLink.new(uri.gsub("//",""))])
				plugin.send_object view
			end
			plugin.request_completed
		end
	end
	
	listen_for /actualité(.*)jour/i do |ph|
		latitude = @latitude
		longitude = @longitude
		
		country = ""
		ned = "fr"
		uri = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}&sensor=false&language=fr-FR"
		response = HTTParty.get(uri)
		if response["status"] == "OK"
			components = response["results"][0]["address_components"]
			components.each do |comp|
				if comp["types"].include?("country")
					country = comp["short_name"]
				end
			end
		end
		
		if country == "BE"
			ned = "fr_be"
		elsif country == "CA"
			ned = "fr_ca"
		elsif country == "CH"
			ned = "fr_ch"
		elsif country == "MA"
			ned = "fr_ma"
		elsif country == "SN"
			ned = "fr_sn"
		else
			ned = country.downcase
		end
	
		title = "Actualité"
		uri = "https://news.google.com/"
		flux = "http://fulltextrssfeed.com/news.google.com/news/feeds?pz=1&cf=all&ned=#{ned}&output=rss"
		RSS.new(self,title,uri,flux)
	end
	
end

# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'
require 'json'

class SiriProxy::Plugin::Location < SiriProxy::Plugin
	def initialize(config)
		@googleplaces = config["api_googleplaces"]
		@tomtom = config["api_tomtom"]
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

	listen_for /o(u|ù) suis.je/i do |ph|
		
		#request = SiriGetRequestOrigin.new("Best")
		#send_object request
	
		latitude = @latitude
		longitude = @longitude
		
		if latitude == nil
			say "Je n'ai pas pu trouver votre emplacement."	
		end
		
		uri = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}&sensor=false&language=fr-FR"
		response = HTTParty.get(uri)

		result = ""
		country = ""
		locality = ""
		postal_code = ""
		route = ""
		street_number = ""

		if response["status"] == "OK"
			components = response["results"][0]["address_components"]
			result = response["results"][0]["formatted_address"];
			components.each do |comp|
				if comp["types"].include?("country")
					country = comp["short_name"]
				end
				if comp["types"].include?("locality")
					locality = comp["long_name"]
				end
				if comp["types"].include?("postal_code")
					postal_code = comp["long_name"]
				end
				if comp["types"].include?("route")
					route = comp["long_name"]
				end
				if comp["types"].include?("street_number")
					street_number = comp["long_name"]
				end
				if comp["types"].include?("administrative_area_level_2") and locality.empty?
					locality = comp["long_name"]
				end
			end
		end
		
		if latitude != nil
			map_snippet = SiriMapItemSnippet.new(true)
			siri_location = SiriLocation.new(result, route, locality, "", country, postal_code, latitude, longitude)
			map_snippet.items << SiriMapItem.new(label="#{postal_code} #{locality}", location=siri_location, detailType="CURRENT_LOCATION")
					
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAssistantUtteranceView.new("Vous êtes à #{result}.")
			view.views << map_snippet
			send_object view
		end
		
		request_completed
	end
	
	listen_for /(où est |où sont |où se trouve |où se trouvent |où se situe |où se situent |se rendre à |se rendre au|itinéraire vers |aller à |allez à )(.*)/i do |ph,emplacement|
				
		uri = "http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(emplacement)}&sensor=false&language=fr-FR"
		response = HTTParty.get(uri)

		latitude = ""
		longitude = ""
		result = ""
		country = ""
		locality = ""
		postal_code = ""
		route = ""
		street_number = ""

		if response["status"] == "OK"
			components = response["results"][0]["address_components"]
			result = response["results"][0]["formatted_address"];
			location = response["results"][0]["geometry"]["location"]
			latitude = location["lat"]
			longitude = location["lng"]
			
			long_name = components[0]["long_name"]
			components.each do |comp|
				if comp["types"].include?("country")
					country = comp["short_name"]
				end
				if comp["types"].include?("locality")
					locality = comp["long_name"]
				end
				if comp["types"].include?("postal_code")
					postal_code = comp["long_name"]
				end
				if comp["types"].include?("route")
					route = comp["long_name"]
				end
				if comp["types"].include?("street_number")
					street_number = comp["long_name"]
				end
				if comp["types"].include?("administrative_area_level_2") and locality.empty?
					locality = comp["long_name"]
				end
			end
			
			map_snippet = SiriMapItemSnippet.new(true)
			siri_location = SiriLocation.new(result, route, locality, "", country, postal_code, latitude, longitude)
			map_snippet.items << SiriMapItem.new(label=long_name, location=siri_location, detailType="ADDRESS_ITEM")
					
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAssistantUtteranceView.new("J'ai trouvé cet emplacement pour #{long_name} :")
			view.views << map_snippet
			url = "http:addto.tomtom.com/api/home/v2/georeference?action=add&apikey=#{@tomtom}&latitude=#{latitude}&longitude=#{longitude}&name=#{URI.encode(long_name)}"
			view.views << SiriButton.new("S'y rendre avec TomTom", [OpenLink.new(url)])
			send_object view

		else
			say "Je n'ai trouvé aucun lieu correspondant à #{emplacement}."
		end
		
		request_completed
	end
	
	listen_for /o. puis.je trouver(.*)/i do |keyword|
		
		latitude = @latitude
		longitude = @longitude
		
		if latitude == nil
			say "Je n'ai pas pu trouver votre emplacement."
		else
			radius = 15000
			latlong = "#{latitude},#{longitude}"
		
			keyword = keyword.gsub("près ","").gsub("plus proches","").gsub("plus proche","").gsub("à proximité","").gsub("dans le coin","").gsub("coin ","").gsub("par ","").gsub("la ","").gsub("les ","").gsub("le ","").gsub("des ","").gsub("d'ici ","").gsub("ici ","").gsub("de ","").gsub("du ","").gsub("une ","").gsub("un ","").gsub("dans ","")
			
			uri = "https://maps.googleapis.com/maps/api/place/search/json?location=#{latlong}&radius=#{radius}&keyword=#{URI.encode(keyword)}&sensor=true&key=#{@googleplaces}"

			response = HTTParty.get(uri)

			if response["status"] == "OK"
				add_views = SiriAddViews.new
				add_views.make_root(last_ref_id)
				map_snippet = SiriMapItemSnippet.new
				
				response["results"].each do |result|
					ident = result["id"]
					name = result["name"]
					lat = result["geometry"]["location"]["lat"]
					lng = result["geometry"]["location"]["lng"]
					vicinity = result["vicinity"]
					if result.include?("rating")
						rate = result["rating"]
						nb_review = 1
					else
						rate = 0.0
						nb_review = 0
					end

					location = SiriLocation.new
					location.label = name
					location.street, location.city = vicinity.split(/, /)
					if location.city == nil
						location.city = ""
					end
					location.latitude = lat
					location.longitude = lng
					item = SiriMapItem.new
					item.label = name
					item.location = location
					map_snippet.items << item
				end
				
				utterance = SiriAssistantUtteranceView.new("J'ai trouvé #{response["results"].length} résultats :")
				add_views.views << utterance	
				add_views.views << map_snippet
				send_object add_views
			else
				say "Je n'ai trouvé aucun lieu à proximité."
			end
		
		end
		
		request_completed

	end

end

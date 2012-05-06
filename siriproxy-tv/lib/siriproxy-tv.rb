# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::TV < SiriProxy::Plugin
	def initialize(config)
	# Config here
	end
	listen_for /programme tv(.*)/i do |fin|
	
		if fin != nil and fin.include?("soir")
			evening = true
		else
			evening = false
		end
		
		uri = "http://api.moustique.be/pota/epg/getbroadcasterlist/data.xml"
		page = Net::HTTP.get(URI.parse(uri))
		doc = Document.new(page)

		channels = Hash.new
		doc.elements.each('broadcasters/broadcaster') do |broadcaster|
			id = broadcaster.attributes["id"]
			name = broadcaster.elements["display_name"].text
			image = XPath.match(broadcaster,'logo/url').first.text
			channels[id] = {:name => name, :image => image}
		end

		if channels.empty?
			say "Je n'ai pas pu récupérer la liste des chaines."
			request_completed
			return
		end

		currenttime = Time.now

		if !evening and currenttime.hour <= 5 and currenttime.min < 30
			download_day = currenttime-86400
		else
			download_day = currenttime
		end
		download_day =  download_day.strftime("%Y-%m-%d")

		uri = "http://api.moustique.be/pota/epg/getprograms/#{download_day}/data.xml"
		page = Net::HTTP.get(URI.parse(uri))
		doc = Document.new(page)

		soiree_debut = currenttime.to_s
		soiree_debut[11,8] = "20:00:00"
		soiree_debut = Time.parse(soiree_debut)

		soiree_fin = currenttime.to_s
		soiree_fin[11,8] = "22:00:00"
		soiree_fin = Time.parse(soiree_fin)

		answers = []
		doc.elements.each('programlist/broadcaster') do |broadcaster|
			lignes = []
			id = broadcaster.attributes["id"]
			name = channels[id][:name]
			image = channels[id][:image]
			if id == "295"
				break
			end
			lignes.push(SiriAnswerLine.new("logo",image))
			broadcaster.elements.each("program") do |program|
				title = program.elements["title"].text
				
				starttime = Time.parse(program.elements["starttime"].text)
				endtime = Time.parse(program.elements["endtime"].text)
				
				afficher = false
				if evening and starttime > soiree_debut and starttime < soiree_fin
					afficher = true
				elsif !evening and starttime < currenttime+1800 and endtime > currenttime
					afficher = true
				end
				
				if afficher
					debut = starttime.strftime("%H:%M")
					fin = endtime.strftime("%H:%M")
					lignes.push(SiriAnswerLine.new("#{debut} - #{fin} : #{title}"))
				end
			end
			answers.push(SiriAnswer.new(name, lignes))
		end
		
		view = SiriAddViews.new
		view.make_root(last_ref_id)
		view.views << SiriAnswerSnippet.new(answers)
		send_object view
		
		request_completed
	end	
	
end

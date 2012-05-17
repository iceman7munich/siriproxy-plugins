# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'
require 'nokogiri'

class SiriProxy::Plugin::Loto < SiriProxy::Plugin
	def initialize(config)
	end
	
	listen_for /r.sultat(.*)loto/i do |ph|
		response = HTTParty.get("https://www.fdj.fr/jeux/loto/tirage")
		doc = Nokogiri::HTML(response)

		titles = doc.css("#loto_title")

		result = "#{titles.first.content} : "
		result_spoken = "#{titles.first.content} : "
		doc.css("#listeBoulesloto p").each do |p|
			result += "#{p.content} "
			result_spoken += "#{p.content}, "
		end
		say "Voici les résultats du lotto : "
		say result, spoken: result_spoken

		result = "#{titles[1].content} : "
		result_spoken = "#{titles[1].content} : "
		doc.css("#listeBoulessuperloto p").each do |p|
			result += "#{p.content} "
			result_spoken += "#{p.content}, "
		end
		say "Voici les résultats du super lotto : "
		say result, spoken: result_spoken
		
	end
	
	listen_for /r.sultat(.*)euro million/i do |ph|
		response = HTTParty.get("https://www.fdj.fr/jeux/euromillions/tirage")
		doc = Nokogiri::HTML(response)

		title = doc.css("#euromillions_title").first.content

		result = "#{title} : "
		result_spoken =  "#{title} : "
		doc.css("#listeNumeros p").each do |p|
			result += "#{p.content} "
			result_spoken += "#{p.content}, "
		end
		result_spoken += "Et les étoiles : "
		doc.css("#listeEtoiles p").each do |p|
			result += "#{p.content} "
			result_spoken += "#{p.content}, "
		end
		say "Voici les résultats de l'Euro Millions : "
		say result, spoken: result_spoken
	end
	
end

# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::Blagues < SiriProxy::Plugin
	def initialize(config)
		@dir = File.dirname(__FILE__)
	end
	
	class VieDeMerde
		include HTTParty
		format :xml
	end
	
	listen_for /vie de merde/i do
		uri = "http://www.vdm-iphone.com/v8/fr/random.php?cat=all&num_page=0"
		vdm = VieDeMerde.get(uri)
		if vdm != nil
			items = vdm["root"]["item"]
			rand = rand(items.length)
			say items[rand]["text"]
		end
		request_completed
	end
	
	listen_for /dans ton chat/i do
		begin
			file = File.open(@dir+"/fortunes-dtc", "r:UTF-8")
			contents = file.read
			liste = contents.split('%')
			rand = rand(liste.length-1)
			dtc = liste[rand]
			dtc = dtc.slice(0..dtc.index("--")-1)
			say dtc
		rescue
			say "Désolé, je n'ai pas trouvé la liste des blagues. Pourtant, j'ai bien cherché dans ton chat."
		end
		request_completed
	end
	
	listen_for /chuck norris/i do
		begin
			file = File.open(@dir+"/fortunes-cn", "r:UTF-8")
			contents = file.read
			liste = contents.split('%')
			rand = rand(liste.length-1)
			dtc = liste[rand].strip
			say dtc
		rescue
			say "Chuck Norris n'a pas besoin d'une liste de blagues pour être drôle. C'est la liste des blagues qui a besoin de Chuck Norris."
		end
		request_completed
	end
	
end

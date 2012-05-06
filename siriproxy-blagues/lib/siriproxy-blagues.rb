# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::Blagues < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
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
		file = File.open("/root/.siriproxy/dtc-fortunes", "r:UTF-8")
		contents = file.read
		liste = contents.split('%')
		rand = rand(liste.length-1)
		dtc = liste[rand]
		dtc = dtc.slice(0..dtc.index("--")-1)
		say dtc
		request_completed
	end
	
	listen_for /chuck norris/i do
		file = File.open("/root/.siriproxy/cn-fortunes", "r:UTF-8")
		contents = file.read
		liste = contents.split('%')
		rand = rand(liste.length-1)
		dtc = liste[rand].strip
		say dtc
		request_completed
	end
	
end

# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'
require 'json'
require 'active_support/core_ext'
require 'i18n'

class SiriProxy::Plugin::Definition < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
	end
  
	listen_for /définition (.*)/i do |query|

		query = query.sub('d\'','').sub('l\'','').sub('le ','').sub('du ','').sub('de ','').sub('pour ','')
		query = query.mb_chars.normalize(:kd).to_str.gsub(/\p{Mn}/, '')
		url = "http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q=#{URI.encode(query)}&sl=fr-FR&tl=fr-FR&restrict=pr%2Cde&client=te"

		jsonString = Net::HTTP.get(URI.parse(url))
		jsonString = jsonString.gsub(",200,null)","").gsub("dict_api.callbacks.id100(","")
		jsonString = jsonString.gsub('\\x3c','').gsub('\\x3d','').gsub('\\x3e','').gsub('\\x22','').gsub('\\x26','').gsub("#39;","'")
		json = JSON.parse(jsonString)

		if json["webDefinitions"] != nil
			definition = json["webDefinitions"][0]["entries"][0]["terms"][0]["text"]
		else
			definition = "Je n'ai trouvé aucune définition"
		end
		say definition

		request_completed
	end
	
end

# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'

class SiriProxy::Plugin::HoroscopeFr < SiriProxy::Plugin
	def initialize(config)
		#if you have custom configuration options, process them here!
	end

	class AstroCenter
	  include HTTParty
	  format :xml
	end
  
	listen_for /horoscope (.*)/i do |signe|

		if signe.include?("belier") or signe.include?("bélier")
			signe_id = 0
		elsif signe.include?("taureau")
			signe_id = 1
		elsif signe.include?("gémeaux")
			signe_id = 2
		elsif signe.include?("cancer")
			signe_id = 3
		elsif signe.include?("lion")
			signe_id = 4
		elsif signe.include?("vierge")
			signe_id = 5
		elsif signe.include?("balance")
			signe_id = 6
		elsif signe.include?("scorpion")
			signe_id = 7
		elsif signe.include?("sagittaire")
			signe_id = 8
		elsif signe.include?("capricorne")
			signe_id = 9
		elsif signe.include?("verseau")
			signe_id = 10
		elsif signe.include?("poisson")
			signe_id = 11
		else
			signe_id = 0
		end

		uri = "http://www.astrocenter.fr/fr/feeds/rss-horoscope-jour-signe.aspx?sign=#{signe_id}"
		astro = AstroCenter.get(uri)
		if astro != nil
			h = astro.parsed_response["rss"]["channel"]["item"]["description"]
			h = h.slice(0..h.index("<br/>")-1)
			say h
		end

		request_completed #always complete your request! Otherwise the phone will "spin" at the user!
	end
	
end

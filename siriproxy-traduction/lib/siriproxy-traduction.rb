# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'httparty'
require 'json'

class SiriProxy::Plugin::Traduction < SiriProxy::Plugin
	def initialize(config)
		@bingtranslation = config["api_bingtranslation"]
	end
	
	listen_for /(Traduit|Traduire|Traduis)(.*) en (.*)/i do |ph,term,lang|
		lang = lang.strip.downcase
		target = ""
		
		languages = {
			"anglais" => "en","arabe" => "ar","bulgare" => "gb","catalan" => "ca","chinois" => "zh-CHS","chinois traditionnel" => "zh-CHT",
			"tchèque" => "cs","tcheque" => "cs","dannois" => "da","nerlandais" => "nl","nérlandais" => "nl","néerlandais" => "nl",
			"estonien" => "et","finnois" => "fi","français" => "fr","francais" => "fr","allemand" => "de","grec" => "el","haitien" => "ht",
			"haïtien" => "ht","hebreu" => "he","hébreu" => "he","hindi" => "hi","hongrois" => "hu","indonésien" => "id","indonesien" => "id",
			"italien" => "it","japonais" => "ja","coréen" => "ko","coreen" => "ko","letton" => "lv","lituanien" => "lt","norvegien" => "no",
			"norvégien" => "no","polonais" => "pl","portugais" => "pt","roumain" => "ro","russe" => "ru","slovaque" => "sk","slovène" => "sl",
			"slovene" => "sl","espagnol" => "es","suédois" => "sv","suedois" => "sv","thai" => "th","thaï" => "th","turc" => "tr",
			"ukrainien" => "uk","vietnamien" => "vi","flamand" => "nl",
		}

		languages.each do |name,code|
			if lang.include?(name)
				target = code
				break
			end
		end

		if target.empty?
			say "Je ne connais pas cette langue."
		else
			begin
				uri = "http://api.bing.net/json.aspx?Query=#{URI.encode(term)}&Translation.SourceLanguage=fr&Translation.TargetLanguage=#{target}&Version=2.2&AppId=#{@bingtranslation}&Sources=Translation" 
				response = HTTParty.get(uri)
				traduction = response["SearchResponse"]["Translation"]["Results"][0]["TranslatedTerm"]
			rescue
				traduction = ""
			end

			if !traduction.empty?
				say traduction
			else
				say "Je n'arrive pas à traduire #{term} en #{lang}"
			end
		end
		request_completed
	end
end
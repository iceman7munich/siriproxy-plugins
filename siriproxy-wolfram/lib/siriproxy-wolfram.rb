# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'json'
require 'httparty'
require 'rexml/document'
require 'nokogiri'
include REXML

class SiriProxy::Plugin::Wolfram < SiriProxy::Plugin
	def initialize(config)
		@apikey = config["api_wolfram"]
		@bingtranslation = config["api_bingtranslation"]
	end
  
	listen_for /(Wolfram |Die |Wie viele von |Qu..tais |Wie lange|Wie viele sind |Welche Entfernung|Wenn ist |Montre moi |Hoehe |wurde wie tief |was ist |Que vaux |Wie viel Wert ist)(.*)/i do |question,query|

		#wolframQuestion = query.sub("+","%2B").sub("d'","").sub("l'","").sub("le ","").sub("la ","").sub("les ","").sub("un ","").sub("une ","").sub("de ","").sub("du ","").sub("des ","")
		wolframQuestion = query.sub(" plus "," + ")

		begin
			uri = "http://api.bing.net/json.aspx?Query=#{URI.encode(wolframQuestion)}&Translation.SourceLanguage=de&Translation.TargetLanguage=en&Version=2.2&AppId=#{@bingtranslation}&Sources=Translation" 
			response = HTTParty.get(uri)
			traduction = response["SearchResponse"]["Translation"]["Results"][0]["TranslatedTerm"]
		rescue
			traduction = wolframQuestion
		end

		traduction = traduction.sub("+","%2B")
		url = "http://api.wolframalpha.com/v1/query.jsp?input=#{URI.encode(traduction)}&appid=#{URI.encode(@apikey)}&translation=true"
		page = Net::HTTP.get(URI.parse(url))
		doc = Document.new(page)
		
		if doc.root.attributes["success"] == "true"
			say "Dies ist Ihre Antwort: "
			answers = []
			doc.elements.each("queryresult") do |node|
				node.elements.each("pod") do |pod|		
					title = pod.attributes["title"]
					pod.elements.each("subpod") do |subpod|			
						plaintext = subpod.elements["plaintext"].text
						image = subpod.elements["img"].attributes["src"]
						if image.nil?
							answers.push(SiriAnswer.new(title, [SiriAnswerLine.new(plaintext)]))
						else
							answers.push(SiriAnswer.new(title, [SiriAnswerLine.new("logo",image)]))
						end
					end
				end
			end
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAnswerSnippet.new(answers)
			send_object view

		else
			say "Ich habe keine Antwort auf deine Frage gefunden!"
		end
		request_completed
	end
end

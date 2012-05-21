# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'json'
require 'httparty'
require 'rexml/document'
include REXML

class SiriProxy::Plugin::Wolfram < SiriProxy::Plugin
	def initialize(config)
		@apikey = config["api_wolfram"]
		@bingtranslation = config["api_bingtranslation"]
	end
  
	listen_for /(Wolfram |Qui est |Combien de |Qu..tais |Combien de temps |Combien font |A quelle distance |Quand est |Montre moi |a quelle hauteur |a quelle profondeur |Quelle est |Quel est |Que vaux |Que vaut )(.*)/i do |question,query|

		#wolframQuestion = query.sub("+","%2B").sub("d'","").sub("l'","").sub("le ","").sub("la ","").sub("les ","").sub("un ","").sub("une ","").sub("de ","").sub("du ","").sub("des ","")
		wolframQuestion = query.sub(" plus "," + ")

		begin
			uri = "http://api.bing.net/json.aspx?Query=#{URI.encode(wolframQuestion)}&Translation.SourceLanguage=fr&Translation.TargetLanguage=en&Version=2.2&AppId=#{@bingtranslation}&Sources=Translation" 
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
			say "Cela pourrait répondre à votre question : "
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
			say "Je n'ai trouvé aucune réponse à votre question !"
		end
		request_completed
	end
end

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
	end
  
	listen_for /(Wolfram |Qui est |Combien de |Qu..tais |Combien de temps |Combien font |A quelle distance |Quand est |Montre moi |a quelle hauteur |a quelle profondeur |Quelle est |Quel est |Que vaux |Que vaut )(.*)/i do |question,query|

		wolframQuestion = query.sub("d'","").sub("l'","").sub("le ","").sub("la ","").sub("les ","").sub("un ","").sub("une ","").sub("de ","").sub("du ","").sub("des ","")
		puts wolframQuestion
		url = "http://api.wolframalpha.com/v1/query.jsp?input=#{URI.encode(wolframQuestion)}&appid=#{URI.encode(@apikey)}&translation=true"
		page = Net::HTTP.get(URI.parse(url))
		doc = Document.new(page)
		
		count_wolfram = 0
		wolfram0 = 12
		wolfram_pod0 = 12
		wolfram0_img = 12
		wolfram1 = 12
		wolfram_pod1 = 12
		wolfram1_img = 12
		wolfram2 = 12
		wolfram_pod2 = 12
		wolfram2_img = 12
		wolfram3 = 12
		wolfram_pod3 = 12
		wolfram3_img = 12
		wolfram4 = 12
		wolfram_pod4 = 12
		wolfram4_img = 12
		wolfram5 = 12
		wolfram_pod5 = 12
		wolfram5_img = 12
		wolfram6 = 12
		wolfram_pod6 = 12
		wolfram6_img = 12
		wolfram7 = 12
		wolfram_pod7 = 12
		wolfram7_img = 12
		wolfram8 = 12
		wolfram_pod8 = 12
		wolfram8_img = 12
		wolframAnswer = 12
		wolframAnswer2 = 12
		wolframAnswer3 = 12
		wolframAnswer4 = 12
		wolframAnswer8 = 12
	
		doc.elements.each('queryresult') do |node|
			node.elements.each('pod') do |pod|
				xmlTag = XPath.match(doc, "//plaintext")[count_wolfram] 
				xmlData = xmlTag.to_s.gsub("<plaintext>","").gsub("</plaintext>","")
				
				if count_wolfram == 0
					if xmlData == "<plaintext/>"
						image_list = XPath.match(doc, "//img")[count_wolfram]
						image_type = image_list.attributes["src"]
						wolfram0 = image_type
						wolfram0_img = 1
					else
						wolfram0 = xmlData
					wolfram_pod0 = pod.attributes["title"]
					end
				elsif count_wolfram == 1
					if xmlData == "<plaintext/>"
						image_list = XPath.match(doc, "//img")[count_wolfram]
						image_type = image_list.attributes["src"]
						wolfram1 = image_type
						wolfram1_img = 1
					else
						wolfram1 = xmlData
					wolfram_pod1 = pod.attributes["title"]
					end
				elsif count_wolfram == 2
					if xmlData == "<plaintext/>"
						image_list = XPath.match(doc, "//img")[count_wolfram]
						image_type = image_list.attributes["src"]
						wolfram2 = image_type
						wolfram2_img = 1
					else
						wolfram2 = xmlData
					wolfram_pod2 = pod.attributes["title"]
					end
				elsif count_wolfram == 3
					if xmlData == "<plaintext/>"
						image_list = XPath.match(doc, "//img")[count_wolfram]
						image_type = image_list.attributes["src"]
						wolfram3 = image_type
						wolfram3_img = 1
					else
						wolfram3 = xmlData
					wolfram_pod3 = pod.attributes["title"]
					end
				elsif count_wolfram == 4
					if xmlData == "<plaintext/>"
						image_list = XPath.match(doc, "//img")[count_wolfram]
						image_type = image_list.attributes["src"]
						wolfram4 = image_type
						wolfram4_img = 1
					else
						wolfram4 = xmlData
					wolfram_pod4 = pod.attributes["title"]
					end
				elsif count_wolfram == 5
					wolfram5 = xmlData
					wolfram_pod5 = pod.attributes["title"]
				elsif count_wolfram == 6
					wolfram6 = xmlData
					wolfram_pod6 = pod.attributes["title"]
				elsif count_wolfram == 7
					wolfram7 = xmlData
					wolfram_pod7 = pod.attributes["title"]
				elsif count_wolfram == 8
					wolfram8 = xmlData
					wolfram_pod8 = pod.attributes["title"]
				end
				count_wolfram += 1
			end
		end

		if wolfram_pod0 != 12
			if wolfram0_img == 1
				wolframAnswer = SiriAnswer.new(wolfram_pod0, [SiriAnswerLine.new("logo", "#{wolfram0}")])
			else
				wolframAnswer = SiriAnswer.new(wolfram_pod0, [SiriAnswerLine.new("#{wolfram0}")])
			end
		end
		if wolfram_pod1 != 12
			if wolfram1_img == 1
				wolframAnswer1 = SiriAnswer.new(wolfram_pod1, [SiriAnswerLine.new("logo", "#{wolfram1}")])
			else
				wolframAnswer1 = SiriAnswer.new(wolfram_pod1, [SiriAnswerLine.new("#{wolfram1}")])
			end
		end
		if wolfram_pod2 != 12
			if wolfram2_img == 1
				wolframAnswer2 = SiriAnswer.new(wolfram_pod2, [SiriAnswerLine.new("logo", "#{wolfram2}")])
			else
				wolframAnswer2 = SiriAnswer.new(wolfram_pod2, [SiriAnswerLine.new("#{wolfram2}")])
			end
		end
		if wolfram_pod3 != 12
			if wolfram3_img == 1
				wolframAnswer3 = SiriAnswer.new(wolfram_pod3, [SiriAnswerLine.new("logo", "#{wolfram3}")])
			else
				wolframAnswer3 = SiriAnswer.new(wolfram_pod3, [SiriAnswerLine.new("#{wolfram3}")])
			end
		end
		if wolfram_pod4 != 12
			if wolfram4_img == 1
				wolframAnswer4 = SiriAnswer.new(wolfram_pod4, [SiriAnswerLine.new("logo", "#{wolfram4}")])
			else
				wolframAnswer4 = SiriAnswer.new(wolfram_pod4, [SiriAnswerLine.new("#{wolfram4}")])
			end
		end
		if wolfram_pod8 != 12
			if wolfram8_img == 1
				wolframAnswer8 = SiriAnswer.new(wolfram_pod8, [SiriAnswerLine.new("logo", "#{wolfram8}")])
			else
				wolframAnswer8 = SiriAnswer.new(wolfram_pod8, [SiriAnswerLine.new("#{wolfram8}")])
			end
		end

		if wolfram_pod0 != 12
			say "Cela pourrait répondre à votre question : "
		end

		if wolfram_pod0 == 12
			say "Je n'ai trouvé aucune réponse à votre question !"
		else
			if wolfram_pod1 == 12
				answers = [wolframAnswer]
			elsif wolfram_pod2 == 12
				answers = [wolframAnswer, wolframAnswer1]
			elsif wolfram_pod3 == 12
				answers = [wolframAnswer, wolframAnswer1, wolframAnswer2]
			elsif wolfram_pod4 == 12
				answers = [wolframAnswer, wolframAnswer1, wolframAnswer2, wolframAnswer3]
			elsif wolfram_pod8 == 12
				answers = [wolframAnswer, wolframAnswer1, wolframAnswer2, wolframAnswer3, wolframAnswer4]
			else
				answers = [wolframAnswer, wolframAnswer1, wolframAnswer2, wolframAnswer3, wolframAnswer4, wolframAnswer8]
			end
			
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAnswerSnippet.new(answers)
			send_object view
		end		
		
		request_completed
	end
	
end

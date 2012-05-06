# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'
require 'imdb'

class SiriProxy::Plugin::ImdbPlugin < SiriProxy::Plugin
	def initialize(config)
	# Config here
	end
	
	def getFilm(name)
		search = Imdb::Search.new(name)
		if search.movies.length >= 1
			return search.movies[0]
		else
			say "Je ne trouve pas le film {0}"
			request_completed
			return nil
		end
	end

	listen_for /(qui a joué dans le film|qui a joué dans|qui joue dans le film|qui joue dans|acteurs? du film|acteurs? de) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			lignes = []
			mains = []
			movie.cast_members.each do |member|
				lignes.push(SiriAnswerLine.new("#{member}"))
				if mains.length < 3
					mains.push(member)
				end
			end
			
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAssistantUtteranceView.new("Les acteurs principaux du film '#{movie.title}' sont #{mains.join(', ')}.")
			view.views << SiriAnswerSnippet.new([SiriAnswer.new("Liste des acteurs", lignes)])
			send_object view
		end
		request_completed
	end	
	
end

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
			say "Je ne trouve pas le film #{name}"
			request_completed
			return nil
		end
	end

	listen_for /(qui a joué dans le film|qui a joué dans|qui joue dans le film|qui est dans le film|qui joue dans|acteurs? du film|acteurs? de) (.*)/i do |ph,film|
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
	
	listen_for /(note du film|quelle est la note de) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			say "#{movie.title} a une note de #{movie.rating}/10."
		end
		request_completed
	end
	
	listen_for /(devrai..je voir le film|devrai..je regarder le film|devrai. regarder le film|devrai. voir le film|que vau. le film) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			rt = movie.rating
			if rt < 6
				say "Vous ne devriez probablement pas le regarder."
			elsif rt < 8
				say "Vous devriez probablement le regarder."
			else
				say "Vous devriez le voir absolument."
			end
			say "#{movie.title} a une note de #{movie.rating}/10."
		end
		request_completed
	end
	
	listen_for /(qui est l.acteur principal|acteur principal du film|acteur principal de) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			say "L'acteur principal du film #{movie.title} est #{movie.cast_members.first}."
		end
		request_completed
	end
	
	listen_for /(qui a réalisé le film|qui réalise le film|réalisateur du film) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			say "Le réalisateur du film #{movie.title} est #{movie.director.first}."
		end
		request_completed
	end
		
	listen_for /(quand est sorti le film|sortie du film|date le film) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			say "Le film #{movie.title} est sorti le #{movie.release_date}."
		end
		request_completed
	end
	
	listen_for /(affiche du film) (.*)/i do |ph,film|
		movie = getFilm(film)
		if movie != nil
			image = movie.poster
			view = SiriAddViews.new
			view.make_root(last_ref_id)
			view.views << SiriAssistantUtteranceView.new("Voilà l'affiche du film #{movie.title} :")
			view.views << SiriAnswerSnippet.new([SiriAnswer.new(movie.title,[SiriAnswerLine.new("logo",image)])])
			send_object view			
		end
		request_completed
	end
	
end

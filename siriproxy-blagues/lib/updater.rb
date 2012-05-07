# -*- encoding : utf-8 -*-
require 'pp'
require 'net/http'
require 'pathname'

def updateFiles(dir, override)
	begin
		Dir::mkdir(dir)
	rescue
		puts "Directory already exists"
	end
	file_dtc = dir+"/fortunes-dtc"
	file_cn = dir+"/fortunes-cn"
	
	if !File.exists?(file_dtc) or override
		puts "Downloading Danstonchat.com's fortunes..."
		Net::HTTP.start("danstonchat.com") do |http|
			resp = http.get("/fortunes")
			open(file_dtc, "wb") do |file|
				file.write(resp.body)
			end
		end
		puts "Done."
	else
		puts "Danstonchat.com's fortunes file already exists"
	end
	
	if !File.exists?(file_cn) or override
		puts "Downloading Chuck Norris's fortunes..."
		Net::HTTP.start("chucknorrisfacts.fr") do |http|
			resp = http.get("/fortunes/fortunes.txt")
			open(file_cn, "wb") do |file|
				file.write(resp.body)
			end
		end
		puts "Done."
	else
		puts "Chuck Norris's fortunes file already exists"
	end
end

# En cas d'exécution directe de updater.rb, on force la mise à jour des fichiers
if __FILE__ == $0
	dir = File.dirname(__FILE__)
	updateFiles(dir, true)
end

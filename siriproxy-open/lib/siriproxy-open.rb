# -*- encoding : utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'

class SiriProxy::Plugin::Open < SiriProxy::Plugin
	def initialize(config)
	end
	
	class ClientBoundCommand < SiriObject
		def initialize(encodedClassName, groupIdentifier, aceId=nil, refId=nil, callbacks=[])
			super(encodedClassName, groupIdentifier)
			self.aceId= aceId
			self.refId = refId
			self.callbacks = callbacks
		end
	end
	add_property_to_class(ClientBoundCommand, :aceId)
	add_property_to_class(ClientBoundCommand, :refId)
	add_property_to_class(ClientBoundCommand, :callbacks)

	class WebSearch < ClientBoundCommand
		def initialize(refId=nil, aceId=nil, query="", provider="Default", targetAppId="")
			super("Search", "com.apple.ace.websearch", aceId, refId)
			self.query = query
			self.provider = provider
			self.targetAppId = targetAppId
		end
	end
	add_property_to_class(WebSearch, :query)
	add_property_to_class(WebSearch, :provider)
	add_property_to_class(WebSearch, :targetAppId)
  
	listen_for /ouvrir(.*)/i do |query|
		search = WebSearch.new(last_ref_id,"",query,"Bing")
		send_object search
		request_completed
	end
	
end

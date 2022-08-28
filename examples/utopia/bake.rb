# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

# Prepare the application for start/restart.
def deploy
	# This task is typiclly run after the site is updated but before the server is restarted.
end

# Restart the application server.
def restart
	call 'falcon:supervisor:restart'
end

# Start the development server.
def default
	call 'utopia:development'
end

def migrate
	call 'utopia:environment'
	
	require 'chat'
	
	Async do
		client = Chat::Database.instance
		session = client.session
		
		result = session.clause("DROP TABLE IF EXISTS").identifier("todo").call
		
		result = session.clause("CREATE TABLE").identifier("todo")
			.clause("(")
				.identifier("id").clause("serial PRIMARY KEY,")
				.identifier("description").clause("TEXT,")
				.identifier("created_at").clause("TIMESTAMP NOT NULL,")
				.identifier("completed_at").clause("TIMESTAMP")
			.clause(")").call
	end
end

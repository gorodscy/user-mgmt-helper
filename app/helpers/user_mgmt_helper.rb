module UserMgmtHelper
	require "net/http"
	require "uri"

	def sign_up user, host='http://localhost:3000'
		raise ArgumentError.new 'User has to be a Hash.' unless user.is_a? Hash

		if valid_simple_user? user
			method = :simple
		elsif valid_oauth_user? user
			method = :oauth
		else
			raise ArgumentError.new 'Invalid/missing atributes for user.'
		end	

		uri = URI.parse(host)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri << '/users', initheader = {'Content-Type' =>'application/json'})
		request.body = { user: user, method: method }.to_json
		response = http.request(request)
		return response.body
	end

	private

		def valid_simple_user? user
			return (user.has_key? "email") && 
						 (user.has_key? "password") && 
						 (user.has_key? "password_confirmation")
		end

		def valid_oauth_user? user
			return (user.has_key? "uid") && 
						 (user.has_key? "strategy")
		end

end

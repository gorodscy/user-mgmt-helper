module UserMgmtHelper
	require "net/http"
	require "uri"

	def sign_up email, password, password_confirmation, host='http://localhost:3000'
		send_request :post, :users, { user: { email: email, password: password, 
			password_confirmation: password_confirmation }, method: :simple }, host
	end

	def sign_up_oauth uid, strategy, email, host='http://localhost:3000'
		send_request :post, :users, { user: { uid: uid, strategy: strategy, email: email }, method: :oauth }, host
	end

	def log_in email, password, host='http://localhost:3000'
		send_request :get, :login, { user: { email: email, password: password }, method: :simple }, host
	end

	def log_in_oauth uid, strategy, host='http://localhost:3000'
		send_request :get, :login, { user: { uid: uid, strategy: strategy }, method: :oauth }, host
	end

	def log_out umid, host='http://localhost:3000'
		send_request :delete, :logout, { user: umid }, host
	end

	def user_info session, host='http://localhost:3000'
		send_request :get, :user_info, { session_id: session }, host
	end

	def add_strategy uid, strategy, umid, session, host='http://localhost:3000'
		send_request :post, :add_strategy, { new_strategy: { uid: uid, strategy: strategy }, 
																				 user: umid, session_id: session }, host
	end

	def remove_strategy umid, strategy, session, host='http://localhost:3000'
		send_request :delete, :remove_strategy, { user: umid, strategy: strategy, 
																							session_id: session }, host
	end

	def delete_user umid, session, host='http://localhost:3000'
		send_request :delete, :destroy, { user: umid, session_id: session }, host
	end

	def change_password user, password, new_pw, new_pw_confirm, session, host='http://localhost:3000'
		send_request :put, :change_password, { user: user, password: password, 
									new_password: new_pw, new_password_confirmation: new_pw_confirm, 
									session: session }, host
	end

	def reset_password reset_token, new_pw, new_pw_confirm, host='http://localhost:3000'
		send_request :put, :change_password, { reset_token: reset_token, new_password: new_pw, 
									new_password_confirmation: new_pw_confirm }, host
	end

	def reset_password_request email, host='http://localhost:3000'
		send_request :post, :reset_password, { email: email }, host
	end

	def change_email user, password, new_email, new_email_confirm, session, host='http://localhost:3000'
		send_request :put, :change_email, { email: user, password: password, new_email: new_email, 
									new_email_confirmation: new_email_confirm, session: session }, host
	end

	private

		def send_request method, path='/', params={}, host='http://localhost:3000'
			path = path.to_s.downcase
			path = '/' << path unless path.start_with? '/'
			uri = URI.parse(host)
			http = Net::HTTP.new(uri.host, uri.port)

			case method.to_s.downcase
				when 'get'
				request = Net::HTTP::Get.new(uri.request_uri << path, initheader = {'Content-Type' =>'application/json'})
				when 'post'
				request = Net::HTTP::Post.new(uri.request_uri << path, initheader = {'Content-Type' =>'application/json'})
				when 'put'
				request = Net::HTTP::Put.new(uri.request_uri << path, initheader = {'Content-Type' =>'application/json'})
				when 'delete'
				request = Net::HTTP::Delete.new(uri.request_uri << path, initheader = {'Content-Type' =>'application/json'})
			end

			request.body = params.to_json
			response = http.request(request)
			begin
				return JSON.parse(response.body)
			rescue
				return response.body
			end
		end

end

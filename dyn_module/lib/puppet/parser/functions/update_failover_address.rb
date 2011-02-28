require 'rubygems'
require 'net/https'
require 'uri'
require 'json'


module Puppet::Parser::Functions
  newfunction(:update_failover_address, :type => :statement) do |args|
    	# Set the desired parameters on the command line 
	CUSTOMER_NAME = args[0]
	USER_NAME = args[1]
	PASSWORD = args[2]
	ZONE = args[3]
	FQDN = args[4]
	IPADDR = lookupvar('ipaddress')

	# Set up our HTTP object with the required host and path
	url = URI.parse('https://api2.dynect.net/REST/Session/')
	headers = { "Content-Type" => 'application/json' }
	http = Net::HTTP.new(url.host, url.port)
	http.set_debug_output $stderr
	http.use_ssl = true

	# Login and get an authentication token that will be used for all subsequent requests.
	session_data = { :customer_name => CUSTOMER_NAME, :user_name => USER_NAME, :password => PASSWORD }

	resp, data = http.post(url.path, session_data.to_json, headers)
	result = JSON.parse(data)

	auth_token = ''
	if result['status'] == 'success'    
		auth_token = result['data']['token']
	else
		puts "Command Failed:\n"
		# the messages returned from a failed command are a list
		result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
	end

	# New headers to use from here on with the auth-token set
	headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }

	#  Get the failover service
	url = URI.parse("https://api2.dynect.net/REST/Failover/#{ZONE}/#{FQDN}") 
	resp, data = http.get(url.path, headers)

	print 'Get Failover Response: ', data, '\n'; 

	# Parse the failover service into a Ruby structure, replace the ip address then re-generate a json file from it
	failover_service = JSON.parse(data)
	failover_service['data']['address'] = IPADDR
	input = JSON.generate(failover_service['data'])

	#  Put the failover changes back into the system 
	url = URI.parse("https://api2.dynect.net/REST/Failover/#{ZONE}/#{FQDN}") 
	resp, data = http.put(url.path, input, headers)

	print 'Put Failover Response: ', data, '\n'; 

	# Logout
	url = URI.parse('https://api2.dynect.net/REST/Session/')
	resp, data = http.delete(url.path, headers)
	print 'DELETE Session Response: ', data, '\n'; 
  end
end

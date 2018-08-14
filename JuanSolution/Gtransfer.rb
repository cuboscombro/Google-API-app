
require 'google/apis/admin_datatransfer_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'



#For the http request:
require 'net/http'
require 'uri'
require 'json'

require './GLOBAL_VARIABLES'
require './Gsuite'


class Gtransfer

	OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
	APPLICATION_NAME = 'Directory API Ruby Quickstart'.freeze
	CREDENTIALS_PATH = 'Gtransfer/credentials.json'.freeze
	TOKEN_PATH = 'Gtransfer/token.yaml'.freeze
	SCOPE =	['https://www.googleapis.com/auth/admin.datatransfer',
			'https://www.googleapis.com/auth/admin.datatransfer.readonly']



	def authorize
		client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
		token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
		authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
		user_id = 'default'
		credentials = authorizer.get_credentials(user_id)
		if credentials.nil?
		  url = authorizer.get_authorization_url(base_url: OOB_URI)
		  puts 'Open the following URL in the browser and enter the ' \
		       "resulting code after authorization:\n" + url
		  code = gets
		  credentials = authorizer.get_and_store_credentials_from_code(
		    user_id: user_id, code: code, base_url: OOB_URI
		  )
		end
		credentials
	end




	def printAppList
	    service = Google::Apis::AdminDatatransferV1::DataTransferService.new
	    service.client_options.application_name = APPLICATION_NAME
	    service.authorization = authorize

		response = service.list_applications #Google::Apis::AdminDirectoryV1::ApplicationListResponse.new
		response.applications.each {|app|
			puts "Application: #{app.name}    ID: #{app.id}"
		}
	end



	def getAppList
	    service = Google::Apis::AdminDatatransferV1::DataTransferService.new
	    service.client_options.application_name = APPLICATION_NAME
	    service.authorization = authorize

		response = service.list_applications #Google::Apis::AdminDirectoryV1::ApplicationListResponse.new
		return response
	end



	def transferDataCrafted(oldUserMail, newUserMail)
		gsuite = Gsuite.new
		idOldUser = gsuite.getUserID(oldUserMail)
		idNewUser = gsuite.getUserID(newUserMail)
		puts "the ID of #{oldUserMail} is: #{idOldUser}"
		puts "the ID of #{newUserMail} is: #{idNewUser}"

	    service = Google::Apis::AdminDatatransferV1::DataTransferService.new
	    service.client_options.application_name = APPLICATION_NAME
	    service.authorization = authorize

		gtransfer = Gtransfer.new
		appList = gtransfer.getAppList
		sleep(5) #We need to wait some seconds. Otherwise, the token will get the old value on the next statement
		token = service.authorization.access_token
		#puts token

		command = "curl --request POST  'https://www.googleapis.com/admin/datatransfer/v1/transfers'  --header 'Authorization: Bearer #{token}'    --header 'Accept: application/json'    --header 'Content-Type: application/json'    --data '{\"kind\":\"admin#datatransfer#DataTransfer\",\"oldOwnerUserId\":\"#{idOldUser}\",\"newOwnerUserId\":\"#{idNewUser}\",\"applicationDataTransfers\":["
		#puts command

		puts "\nThe applications that will transfer data will be: "
		appList.applications.each{|app|
			puts "#{app.name} with id: #{app.id}"
			appid = app.id.to_s		
			command += "{\"applicationId\":\"#{appid}\",\"applicationTransferParams\":[{\"key\":\"PRIVACY_LEVEL\",\"value\":[\"PRIVATE\",\"SHARED\"]}]},"
		}

		command = command[0...-1] #With this statement, we remove the last comma character in the command in order the JSON to be valid. Example: "{a, b, c," is converted into {a, b, c"
		command += "]}'    --compressed"
		#puts command
		response = %x[curl #{command}]
		puts response
	end




	def extractEmployees(uriX)
		uri = URI(uriX)
		answer = Net::HTTP.get(uri)
		evaluedAnswer = eval answer
		json_answer = JSON.parse(evaluedAnswer.to_json)
		return json_answer['employees']
	end



	def buildMailAddress(firstName, lastName, domain)
	    return "#{firstName}.#{lastName}@#{domain}".downcase
	end



	def getManagerMail(oldUserMail)
		employees = extractEmployees(EMPLOYEES_PATH)

		employees.each { |employee|
			#puts employee
			employeeMail = buildMailAddress(employee['firstName'], employee['lastName'], DOMAIN)
			if employeeMail == oldUserMail
				return employee['managerMail']
			end
		}
		return nil
	end





	def transferData(oldUserMail, newUserMail)
		gsuite = Gsuite.new

		#First, let's check if the source and the destiny users exist
		idOldUser = gsuite.getUserID(oldUserMail)
		if idOldUser == nil
			puts "The source user #{oldUserMail} does not exist! We cannot transfer its data"
			return
		end

		idNewUser = gsuite.getUserID(newUserMail)
		if idNewUser == nil
			puts "The destiny user #{newUserMail} does not exist! We cannot transfer data to him/her"
			return
		end		

		puts "the ID of #{oldUserMail} is: #{idOldUser}"
		puts "the ID of #{newUserMail} is: #{idNewUser}"

	    service = Google::Apis::AdminDatatransferV1::DataTransferService.new
	    service.client_options.application_name = APPLICATION_NAME
	    service.authorization = authorize


		atp = Google::Apis::AdminDatatransferV1::ApplicationTransferParam.new(
	    key: "PRIVACY_LEVEL",
	    value: ["PRIVATE", "SHARED"])

		adtArray = []

		gtransfer = Gtransfer.new
		appList = gtransfer.getAppList

		puts "\nThe applications that will transfer data will be: "
		appList.applications.each{|app|
			puts "#{app.name} with id: #{app.id}"
			appid = app.id.to_s

		    adt = Google::Apis::AdminDatatransferV1::ApplicationDataTransfer.new(
				application_id: appid,
				application_transfer_params: [atp])
			
			adtArray.push(adt)
		}


		dt = Google::Apis::AdminDatatransferV1::DataTransfer.new(
		    kind: "admin#datatransfer#DataTransfer",
		    old_owner_user_id: idOldUser,
		    new_owner_user_id: idNewUser,
		    application_data_transfers: adtArray)

		response = service.insert_transfer(dt)
		puts response
		puts "The Data Transfer has been enqueued correctly on Google servers!\n You will receive an e-mail from Google when it's completed"
	end



	def transferToManager(oldUserMail)
		managerMail = getManagerMail(oldUserMail)
		#puts "The manager is #{managerMail}"
		transferData(oldUserMail, managerMail)
	end




	def isCompleted(dt)
		dt.each{ |adt|
			if adt.application_transfer_status != "completed"
				return false
			end
		}
		return true
	end



	def isTransfered(userMail)
		service = Google::Apis::AdminDatatransferV1::DataTransferService.new
		service.client_options.application_name = APPLICATION_NAME
		service.authorization = authorize

		gsuite = Gsuite.new
		idUser = gsuite.getUserID(userMail)
		puts "the ID of #{userMail} is: #{idUser}"

		listTr = service.list_transfers()
		listTr.data_transfers.each{ |dt|
			if dt.old_owner_user_id == idUser && isCompleted(dt.application_data_transfers) 
					#puts dt.inspect
					return true
			end
		}
		return false
	end


	#gtx = Gtransfer.new
	#response = gtx.transferDataX("alice.mont@mycompany.com", "juan.magraner@mycompany.com")
	#puts response



	#gt = Gtransfer.new
	#result = gt.isTransfered("alicia.montes@mycompany.com")
	#puts result.inspect
	#gt.transferData("peter.london@mycompany.com", "juan.magraner@mycompany.com")




end

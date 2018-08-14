require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

require './GLOBAL_VARIABLES'




def buildOrgUnit(string)
	if string[0] != '/'
		return "/#{string}"
	else
		return string
	end
end


class Gsuite

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Directory API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = 'Gsuite/credentials.json'.freeze
  TOKEN_PATH = 'Gsuite/token.yaml'.freeze
  SCOPE = [Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER,
           Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
           Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP_MEMBER,
           Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT,
           Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT_READONLY
         ]

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
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




  def createGsuiteUser(firstName, surname, password, flywireEmail, personalMail, orgUnit)
    #First let's check if the user exists. If it exists, we will not do anything:
    checkUser = Gsuite.new
    if checkUser.userExists(flywireEmail)
    	puts "The user #{flywireEmail} already exists! We're not going to create the user."
    	return nil
    end

    #Then let's check if the Organizational Unit of the new user exists. If not, let's create it:
    checkOU = Gsuite.new
    if !checkOU.orgUnitExists(orgUnit)
    	puts "The Organizational Unit #{orgUnit} does not exist! We're going to create it"
    	checkOU.createOrgUnit(orgUnit)
    else
    	#puts "The OU exists!"
    end

    # Initialize the API
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    username = Google::Apis::AdminDirectoryV1::UserName.new(given_name: firstName, family_name: surname)
    user = Google::Apis::AdminDirectoryV1::User.new(name: username, password: password, primary_email: flywireEmail, emails: personalMail, org_unit_path: buildOrgUnit(orgUnit)) 

    result = service.insert_user(user)
    puts result
  end



  def userExists(flywireEmail)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # List the users in the domain
    response = service.list_users(customer: 'my_customer',
                                  order_by: 'email')
    response.users.each { |user|
    	if user.primary_email == flywireEmail
    		return true
    	end
    }
    return false
  end



  def deleteGsuiteUser(flywireEmail)
  	#First let's check if the user exists. If it does not exist, we will not do anything:
  	checkUser = Gsuite.new
  	if !checkUser.userExists(flywireEmail)
  		puts "The user #{flywireEmail} does not exist! We cannot delete it."
  		return nil
  	end
      # Initialize the API
      service = Google::Apis::AdminDirectoryV1::DirectoryService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize

      result = service.delete_user(flywireEmail)
      puts "The user #{flywireEmail} was removed successfully!"
      puts result
  end



  def getGsuiteUsers
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    # List the first 400 users in the domain
    response = service.list_users(customer: 'my_customer',
                                  order_by: 'email')
    puts 'Users:'
    puts 'No users found' if response.users.empty?
    response.users.each { |user| puts "- #{user.primary_email} (#{user.name.full_name}) #{user.org_unit_path} #{user.customer_id}" }
  end



  def getGsuiteFullName(mailAddress)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    # List the first 400 users in the domain
    response = service.list_users(customer: 'my_customer',
                                  order_by: 'email')
    response.users.each { |user|
      if user.primary_email == mailAddress
	    return user.name.full_name
      end
    }
    return ""
  end




  def orgUnitExists(orgUnitPath)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    response = service.list_org_units(customer='my_customer')
    response.organization_units.each {|orgUnit|
	  #puts "Path: #{orgUnit.org_unit_path} Name:#{orgUnit.name}"
	  if  orgUnit.org_unit_path == orgUnitPath || orgUnit.name == orgUnitPath
	  	return true
	  end
    }
    return false
  end




  def createOrgUnit(nameX)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    orgUnit = Google::Apis::AdminDirectoryV1::OrgUnit.new
    if nameX[0] == "/"
    	orgUnit.name = nameX[1, nameX.length - 1]
    else
    	orgUnit.name = nameX
    end

    orgUnit.parent_org_unit_path = '/'
    response = service.insert_org_unit("my_customer", orgUnit)
  end





  def getUsersGroup
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    response = service.list_members()
  end



  def getGroups
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    response = service.list_groups(customer: "my_customer", domain: DOMAIN)
    #puts response.inspect
  end



  def addUserGroup(groupMail, userMail)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    member = Google::Apis::AdminDirectoryV1::Member.new
    member.email = userMail
    member.role = "MEMBER"
    response = service.insert_member(groupMail, member)
  end



  def addManagerGroup(groupMail, userMail)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    member = Google::Apis::AdminDirectoryV1::Member.new
    member.email = userMail
    member.role = "MANAGER"
    response = service.insert_member(groupMail, member)
  end


  def getUserID(flywireEmail)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    # List the users in the domain
    response = service.list_users(customer: 'my_customer',
                                  order_by: 'email')
    response.users.each { |user|
    	if user.primary_email == flywireEmail
    		return user.id
    	end
    }
    return nil
  end


  def generateRandomPassword
    downcase = [('a'..'z')].map(&:to_a).flatten
    upcase = [('A'..'Z')].map(&:to_a).flatten
    symbols = [('#'..'.')].map(&:to_a).flatten
    numbers = [('0'..'9')].map(&:to_a).flatten
    string =  downcase[rand(downcase.length)]
    string += upcase[rand(upcase.length)]
    string += symbols[rand(symbols.length)]
    string += numbers[rand(numbers.length)]
    string += downcase[rand(downcase.length)]
    string += upcase[rand(upcase.length)]
    string += symbols[rand(symbols.length)]
    string += numbers[rand(numbers.length)]
    return string
  end



  def getUser(flywireEmail)
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # List the users in the domain
    response = service.list_users(customer: 'my_customer',
                                  order_by: 'email')
    response.users.each { |user|
      if user.primary_email == flywireEmail
        return user
      end
    }
    return nil
  end



  def updatePassword(flywireEmail)
    randomPassword = generateRandomPassword
    #puts randomPassword

    gsuite = Gsuite.new
    userNew = gsuite.getUser(flywireEmail)
    userNew.password = randomPassword

    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    response = service.update_user(flywireEmail, userNew)
    puts response
    puts "The user #{flywireEmail} 's new password is #{randomPassword}"
  end




end

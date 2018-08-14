require 'mail'
require 'net/http'
require 'json'


require './GLOBAL_VARIABLES'
require './Gmail'
require './Gsuite'





class Onboarding

	def extractEmployees(uriX)
		uri = URI(uriX)
		answer = Net::HTTP.get(uri)
		evaluedAnswer = eval answer
		json_answer = JSON.parse(evaluedAnswer.to_json)
		return json_answer['employees']
	end




	def buildBodyMail(employee)
		gsuitSample = Gsuite.new
		managerName = gsuitSample.getGsuiteFullName(employee['managerMail'])

		#if the manager's full name appears blank, let's return the manager's mail:
		if managerName == ""
			managerName == employee['managerMail']
		end

		bodyMail = "Name and surname: #{employee['firstName']} #{employee['lastName']} \n"
		bodyMail += "Job title: #{employee['jobTitle']} \n"
		bodyMail += "Manager name and surname: #{managerName} \n"
	end



	def buildMailAddress(firstName, lastName, domain)
	    return "#{firstName}.#{lastName}@#{domain}".downcase
	end



	def buildMailSignature(firstName, lastName, jobTitle, mailAddress)
	    return "#{firstName} #{lastName} \n #{jobTitle} \n #{mailAddress}"
	end



	def buildMailWithPassword(firstName, lastName, mailAddress, password)
		stringAux = "#{firstName} #{lastName} has joined the company\n"
		stringAux +=  "His/her mail address is #{mailAddress} and the password is #{password}"
		return stringAux
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



	def sendTicket(employee)
		#puts employee
		bodyMail = buildBodyMail(employee)
		#puts bodyMail
		mailSample = Gmail.new
		mailSample.sendGmail("juan.magraner@mycompany.com",
							PRODUCTION ? TICKETS_MAIL : "juan.magraner@mycompany.com", #In production, this parameter changes to "ticket_system@mycompany.com"
							"New Employee!",
							bodyMail) 
	end



	def createGsuiteAccount(employee, randomPassword)
		mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
		puts mailAddress

		gsuitSample = Gsuite.new
		gsuitSample.createGsuiteUser(employee['firstName'], employee['lastName'], randomPassword, mailAddress, employee['privateMail'], employee['department'])
	end



	def addUserEmployeesGroup(employee)
		mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
		gsuitSample = Gsuite.new
		gsuitSample.addUserGroup("employees@mycompany.com", mailAddress)
	end



	def setMailSignature(employee) #When Google will release the functionality of setting other users' signature, we will place it here
		mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
		mailSignature = buildMailSignature(employee['firstName'], employee['lastName'], employee['jobTitle'], mailAddress)
		puts mailSignature 
	end



	def sendPasswordToManager(employee, randomPassword)
		mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
		mailWithPassword = buildMailWithPassword(employee['firstName'], employee['lastName'], mailAddress, randomPassword)
		mailSample = Gmail.new
		mailSample.sendGmail("juan.magraner@mycompany.com",
							PRODUCTION ? employee['managerMail'] : "juan.magraner@mycompany.com", #In production, this parameter changes to employee['managerMail']
							"New Employee's info",
							mailWithPassword) 
	end


	def userExists(employee)
		mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
		gsuite = Gsuite.new
		return gsuite.userExists(mailAddress)
	end


	def processEmployee(employee)

		if userExists(employee)
			mailAddress = buildMailAddress(employee["firstName"], employee["lastName"], DOMAIN)
			puts "The employee #{mailAddress} already exists! We're not going to create it"
			return
		end

		#First, let's send a ticket to  ticket_system@mycompany.com informing a new employee has joined the company: 
		sendTicket(employee)

		#Secondly, let's create the Google Suite account with all the required parameters:
		randomPassword = generateRandomPassword
		createGsuiteAccount(employee, randomPassword)

		#Thirdly, let's add the user to the Employees group:
		addUserEmployeesGroup(employee)

		#Fourthly, let's change the mail signature to the new Gmail account:
		setMailSignature(employee)

		#Fifthly, let's send a mail to his/her manager with the password
		sendPasswordToManager(employee, randomPassword)    
	end


	def extractEmpDocuments(uriX)
		uri = URI(uriX)
		answer = Net::HTTP.get(uri)
		evaluedAnswer = eval answer
		json_answer = JSON.parse(evaluedAnswer.to_json)
		return json_answer['employee']['id']

	end

	def processNewEmployee()
		ob = Onboarding.new
		employees = ob.extractEmployees(EMPLOYEES_PATH)

		id = ob.extractEmpDocuments(DOCUMENTS_PATH)

		employees.each { |employee|
			if employee['id'] == id
				p employee
				#ob.processEmployee(employee)
			end
		}
	end



	def processAllEmployees()
		ob = Onboarding.new
		employees = ob.extractEmployees(EMPLOYEES_PATH)

		employees.each { |employee|
			ob.processEmployee(employee)
		}
	end





end








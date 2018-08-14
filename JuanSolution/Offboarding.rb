require './Gmail'
require './Gsuite'
require './Gtransfer'
require './GLOBAL_VARIABLES'


class Offboarding

	def offboard(mailAddressRaw)
		mailAddress = mailAddressRaw.downcase
		#First. let's transfer the user's data to his/her manager
		transfer = Gtransfer.new
		if PRODUCTION
			transfer.transferToManager(mailAddress)
		else #We're in TEST environment, so let's send the user's data to juan.magraner@mycompany.com instead of to the user's Manager
			transfer.transferData(mailAddress, "juan.magraner@mycompany.com")
		end

	end

	def deleteUser(mailAddressRaw)
		mailAddress = mailAddressRaw.downcase
		#Firstly, let's check if the user exists:
		gsuite = Gsuite.new
		if !gsuite.userExists(mailAddress)
			puts "The user #{mailAddress} does not exist! We cannot delete it"
			return
		end
		gsuite = Gsuite.new
		gsuite.deleteGsuiteUser(mailAddress)
	end



	def isTransfered(mailAddressRaw)
		mailAddress = mailAddressRaw.downcase
		gsuite = Gsuite.new

		#First, let's check if the user exists
		idOldUser = gsuite.getUserID(mailAddress)
		if idOldUser == nil
			puts "The user #{mailAddress} does not exist! we cannot check its data transfers"
			return true
		else
			gtransfer = Gtransfer.new
			return gtransfer.isTransfered(mailAddress)
		end
	end



	def changePassword(mailAddressRaw)
		mailAddress = mailAddressRaw.downcase		
		gsuite = Gsuite.new

		#First, let's check if the user exists
		idOldUser = gsuite.getUserID(mailAddress)
		if idOldUser == nil
			puts "The user #{mailAddress} does not exist! we cannot change its password"
			return nil
		else
			gsuite = Gsuite.new
			gsuite.updatePassword(mailAddress)
		end
	end

end
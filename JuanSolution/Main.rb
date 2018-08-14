require './GLOBAL_VARIABLES' 

require './Onboarding'
require './Offboarding'



loop do
	puts "\n********** WE'RE IN THE ENVIRONMENT: " + (PRODUCTION ? "_P_R_O_D_U_C_T_I_O_N_" : "_T_E_S_T_ ") + "**********"
	puts "Option 1: Process all new employees from #{EMPLOYEES_PATH}"
	puts "Option 2: Transfer data of an employee of #{DOMAIN} domain"
	puts "Option 3: Remove an employe from #{DOMAIN} domain"
	puts "Option 4: Change the password of a user"
	print "Type the option: "
	option = gets.chomp


	case option
	when "1"
		on = Onboarding.new
		on.processAllEmployees
	when "2"
		print "Type the e-mail address of the employee to transfer the data: "
		mailAddress = gets.chomp
		off = Offboarding.new
		off.offboard(mailAddress) #This will transfer the data whitout removing the user
	when "3"
		print "Type the e-mail address of the employee that needs to be deleted: "
		mailAddress = gets.chomp
		off = Offboarding.new

		if !off.isTransfered(mailAddress)
			print "The data of user #{mailAddress} has not been transfered yet! Do you still want to delete that user? (y/n): "
			answer = gets.chomp
			if answer == 'y'
				off.deleteUser(mailAddress) 
			end
		else
			off.deleteUser(mailAddress) 
		end
	when "4"
		print "Type the e-mail address of the user whose password needs to be changed: "
		mailAddress = gets.chomp
		off = Offboarding.new
		off.changePassword(mailAddress)
	end
end



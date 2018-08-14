This software aims to provide an easy way to manage the Onboarding and Offboardings of employees in the company. It's is developed in Ruby and can be run either from command line or programmatically.

To use it, the user needs to install the Google API Client gem in the machine. You can do this by running the following command:
gem install google-api-client

Probably you will need to be superuser to launch the command.

In order to make tasks programmatically with Google Apps, the software uses 3 different Google APIS:
- G suite API: for managing user accounts, groups, Organizational Units and similar
- Gmail API: for managing tasks related with Google Mail, such as sending mails.
- Data Transfer API: for managing transfers of data between G suite user accounts

The Google authentication JSON files for those 3 APIS need to be placed in the project folders Gsuite, Gmail and Gtransfer respectively, and they need to be called credentials.json

The first time the software is launched on a specific machine, it will ask to paste a specific code into the browser to authenticate the user. This is done only once per machine and it will create a token.yaml file containing the token for the authentication.
From the second and subsequent times no additional authentication will be needed.

Moreover, in order to achieve the maximum portability, there is file called GLOBAL_VARIABLES.rb in which we can change the value of the global variables in the software only once, without affecting the rest of the software.
For example, if the web server changes its URL in the future, we will only need to change the variable EMPLOYEES_PATH on that file.

The software consists mainly on 6 (let's say) modules that correspond to the following files:
HIGH LAYER:
	- Main.rb: It is the command line interface for launching the application. It calls the methods on the medium layer.

MEDIUM LAYER: 
	- Onboarding.rb: It contains the logic to perform Onboardings on the company. It calls the modules of the low level
	- Offboarding.rb: It contains the logic to perform Offboardings. As Onboarding module, it calls the modules of the low level

LOW LAYER:
	- Gmail, Gsuite and Gtransfer contain the logic to call Google API methods.


When launching the Main.rb module, 2 options are presented: 
- Process all the employees stored on the JSON file in the web server.
- Delete a G suite account from the domain

If the first option is selected, the software will check the JSON file on http://localhost:8001/employees and if there are employees stored, it will:
- Check if the employee exists. If it exists, the system does not try to create it in order to avoid error.
- If it does not exist, the system will create the user's G suite account programmatically (Gmail, Drive, Calendar, etc).
  For security reasons, this software will generate a random password on the fly for the new account. It will contain lower case letters, upper case letters, numbers and symbols.
- Then it will insert the user into the Organizational Unit specified in the JSON file, creating it if it does not exist.
- It will add the user to the Employees group.
- The system will send a mail to ticket_system@mycompany.com informing that a new employee has joined the company. To accomplish that, the global variable PRODUCTIION in the file GLOBAL_VARIABLES.rb needs to be changed to true. 
- It will also send a mail to the employee's manager indicating the temporal password of the new G suite account. For automating this mail, the global variable PRODUCTIION in the file GLOBAL_VARIABLES.rb also needs to be true. 


I aimed to set the mail signature of the new employee programmatically. However, this is not currently possible with the API provided by Google. The Gmail API can change programmatically the mail signature of the user who owns the Google API key, but not others'. It happens so even if the user who launches the request is domain admin. Here are 2 sites confirming the fact:
https://stackoverflow.com/questions/30786709/gmail-api-super-admin-access-other-users-accounts-via-api
https://stackoverflow.com/questions/42623328/google-gmail-api-delegation-settings

I've also encountered the same error, "Delegetion denied", when trying to develop such functionality. The only solution to this is to enable Domain Wide Delegation, which is unsecure from the organization's perspective (for instance, if that account was hacked). The good new is that Google plans to release the delegation functionality to September 2018. Hopefully, we will be able to implement it from our software soon.


 
If we choose the second option from the Main application, it will programmatically transfer the data of the G suite apps to his/her manager.
Please, take note that it is not possible to transfer a user's data once its account has been removed. So when offboarding employees, the procedure should be something like:
1.- To change the user's password
2.- To transfer the user's data with this software. 
3.- Some days afterwards, when we receive the Google confirmation mail about the successful data transfer, then we remove the account.

Right now, when running Main.rb and selecting to transfer data of a user, the logic does not change the user's password nor remove the account. But the logic can be easily changed with the source code I've implemented. 

Furthermore, the functionality of this software can also be used programatically, making it as reusable as possible. I'm going to cite some resources we can use from other applications. 
For example, you can do something like following to call the mailing functionality of this software:

require './Gmail'

...

mail = Gmail.new
mail.sendGmail("juan.magraner@mycompany.com", "customer@company.com", "Software Update", "This mail is to inform you that there is a new version of your product")


We can also do automated tasks with Users. For example, the following command will deterministically create a G suite user in our domain, specifying its name, surname, password, personal mail and the Organizational Unit in which he will be placed:

require './Gsuite'

...

account = Gsuite.new
account.createGsuitUser("Kevin", "Smith", "y8.M4e+D", "ksmith@mycompany.com", "kevin.smith@gmail.com", "/Developers")


This software is in its first version and aims to add more functionality to automatize more tasks on the company.

I'm totally open to explain how this software works and the great possibilities of extending it. Using Google API we can integrate apps for achieving brilliant results.


Juan Magraner

juamagb1@gmail.com


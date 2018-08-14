# Exercise Flow Automation

## Prerequisites
To make this exercise you would need to have Docker Engine and Docker Compose installed in your machine. 
You will find in this repository the docker-compose.yml file.

You'll get also in your personal email the credentials to access to the GSuite environment as admin.

Note: Good code must be properly tested and easily maintained by anyone on the team.

## Background
The company is growing fast and we need to start working in the automation of our onboarding/offboarding process. We want to start use the HR applications as triggers to create/remove access in the different SaaS services that the company offer to their employees.

## What we need from you
We have received a new signed contract (signed_contract.pdf) for a new employee in our documents repository: http://localhost:8000/documents

The personal information about this person has been already added to our HR repository: http://localhost:8001/employees

We need to create an automatic process to do the next things.

1) Create a ticket sending an email to ticket_system@mycompany.com with the next information.
* Name and surname
* Job title
* Manager Name and surname

2) Create an account at Gsuite with the next information
 * Name and surname
 * Corporate email address (format: name.surname@mycompany.com)
 * Personal email
 * The user should be inside the department Organizational Unit (if is a new department we should create that Organizational Unit)
 * Add the user to the Group ‘Employees’
 * Set a email signature for the user with the next information
 	* Name and surname
	* Job role
 * Sent the information of the account to their manager (email address and temporal password)
 
 ## Extra ball
 To improve also the offboarding process we want to create an automatic flow that deletes the user from Gsuite and transfers all the user info (Drive, Calendars, Contacts...) to their Manager.
 

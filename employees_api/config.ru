require 'sinatra'
require 'grape'

class API < Grape::API
  get :employees do
{
    "fields": [
        {
            "id": "displayName",
            "type": "text",
            "name": "Display Name"
        },
        {
            "id": "firstName",
            "type": "text",
            "name": "First Name"
        },
        {
            "id": "lastName",
            "type": "text",
            "name": "Last Name"
        },
        {
            "id": "gender",
            "type": "text",
            "name": "Gender"
        },
        {
            "id": "privateMail",
            "type": "mail",
            "name": "Private Mail"
        },
        {
            "id": "department",
            "type": "list",
            "name": "Department"
        },
        {
            "id": "jobTitle",
            "type": "list",
            "name": "Job Title"
        },
        {
            "id": "workPhone",
            "type": "text",
            "name": "Work Phone"
        },
        {
            "id": "managerMail",
            "type": "mail",
            "name": "Manager Mail"
        },
        {
            "id": "facebook",
            "type": "text",
            "name": "Facebook URL"
        }
    ],
    "employees": [
        {
            "id":123,
            "displayName":"John Doe",
            "firstName":"John",
            "lastName":"Doe",
            "gender":"Male",
            "privateMail":"JohnDoe@fakegmail.com",
	        "department":"Sales",
            "jobTitle":"Customer Service Representative",
            "workPhone":"555-555-5555",
            "managerMail":"manager@mycompany.com",
            "facebook":"JohnDoeFacebook"
        },
        {
            "id":124,
            "displayName":"Peter London",
            "firstName":"Peter",
            "lastName":"London",
            "gender":"Male",
            "privateMail":"Peter_London@fakegmail.com",
	        "department":"IT",
            "jobTitle":"Senior Sysadmin",
            "workPhone":"555-555-5542",
            "managerMail":"manager@mycompany.com",
            "facebook":"PeterLondonFacebook"
        },
        {
            "id":125,
            "displayName":"Sarah Duncan",
            "firstName":"Sarah",
            "lastName":"Duncan",
            "gender":"Female",
            "privateMail":"Sarah123@fakegmail.com",
	        "department":"Helpdesk",
            "jobTitle":"Senior Helpdesk",
            "workPhone":"555-555-5545",
            "managerMail":"manager@mycompany.com",
            "facebook":"SarahFacebook"
        },
        {
            "id":126,
            "displayName":"Alicia Montes",
            "firstName":"Alicia",
            "lastName":"Montes",
            "gender":"Female",
            "privateMail":"AlciaMonty@fakegmail.com",
	    "department":"Operations",
            "jobTitle":"Operations VP",
            "workPhone":"555-555-5342",
            "managerMail":"manager@mycompany.com",
            "facebook":"AliFacebook"
        }

    ]
}
  end
end

class Web < Sinatra::Base
  get '/' do
    'Hello employees.'
  end
end

use Rack::Session::Cookie
run Rack::Cascade.new [API, Web]

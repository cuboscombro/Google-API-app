require 'sinatra'
require 'grape'

class API < Grape::API
  get :documents do
{
  "employee": {
    "id": "123",
    "category": [
      {
        "id": "1",
        "name": "New Hire Docs",
        "file": [
	  {
            "id": "1234",
            "name": "Employee handbook",
            "originalFileName": "employee_handbook.doc",
            "size": "23552",
            "dateCreated": "2011-06-28 16:50:52",
            "createdBy": "John Doe",
            "shareWithEmployee": "yes"
          },
          {
            "id": "1434",
            "name": "Signed Contract",
            "originalFileName": "signed_contract.pdf",
            "size": "23675",
            "dateCreated": "2018-06-28 14:34:42",
            "createdBy": "John Doe",
            "shareWithEmployee": "yes"
          }
        ]
      },
      {
        "id": "112",
        "name": "Training Docs"
      }
    ]
  }
}
   end
end

class Web < Sinatra::Base
  get '/' do
    'Hello documents.'
  end
end
use Rack::Session::Cookie
run Rack::Cascade.new [API, Web]

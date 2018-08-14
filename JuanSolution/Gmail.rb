require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'


class Gmail

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = './Gmail/credentials.json'.freeze
  TOKEN_PATH = './Gmail/token.yaml'.freeze
  SCOPE = ['https://mail.google.com/',
          'https://www.googleapis.com/auth/gmail.settings.basic',
          'https://www.googleapis.com/auth/gmail.settings.sharing']


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





  def sendGmail(from, to, subject, body)
    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    m = Mail.new
    m.date = Time.now
    m.subject = subject
    m.body = body
    m.from = from
    m.to   = to
    msg = m.encoded 
    message_object = Google::Apis::GmailV1::Message.new(raw: m.encoded) # or m.to_s
    service.send_user_message('me', message_object)
  end


  #sendGmail("juan.magraner@mycompany.com", "juan.magraner@mycompany.com", "This is the subject", "This is the body")


  def setSignature(mailAdress, signatureX)
      # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    newSendAs = Google::Apis::GmailV1::SendAs.new
    newSendAs.send_as_email = mailAdress
    newSendAs.signature = signatureX
    newSendAs.is_primary = true
    newSendAs.is_default = true
    #puts newSendAs.display_name
    response = service.patch_user_setting_send_as(mailAdress, mailAdress, newSendAs)
  end


  #gmail = Gmail.new
  #response = gmail.setSignature("juan.magraner@mycompany.com", " ")
  #puts response



end

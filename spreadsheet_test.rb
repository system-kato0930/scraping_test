require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

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

service = Google::Apis::SheetsV4::SheetsService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize
spreadsheet_id = '1SuFFSAAIoU_RZTQiFc9RcKfb5l64kqHL2UkG1ieVdC8'

range = "'テスト'!A:D"
response = service.get_spreadsheet_values(spreadsheet_id, range)
puts 'No data found.' if response.values.empty?
response.values.each do |row|
  puts "#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}"
end

# range = 'A11'
# data = Google::Apis::SheetsV4::ValueRange.new
# data.major_dimension = 'ROWS'
# data.range = 'A11'
# random = rand(100)
# data.values = [["hoge#{random}"]]
# options = {
#   value_input_option: 'RAW'
# }
# response = service.update_spreadsheet_value(spreadsheet_id, range, data, value_input_option: 'RAW')
# puts response.updated_cells

data = Google::Apis::SheetsV4::ValueRange.new
data.major_dimension = 'COLUMNS'
sheet_name_data = "テスト"
result_data = ["在庫状況", "○在庫あり", "○在庫あり", "○在庫あり", "○在庫あり"]
data.values = [result_data]
# range = %('#{sheet_name_data}'!D2:D#{result_data.count+1})
range = %('#{sheet_name_data}'!D2:D#{result_data.count+1})
pp data
response = service.update_spreadsheet_value(spreadsheet_id, range, data, value_input_option: 'RAW')
puts response.updated_cells
require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
# require 'authorize_google.rb'
# require 'stock_cheker'
# selenium-webdriverを取り込む
require 'selenium-webdriver'
# loggerライブラリを読み込み
require 'logger'
require 'uri'

def check_stock(session, url, words)

	# ページ遷移する
	session.navigate.to url

	# ページのタイトルを出力する
	puts %(タイトル：#{session.title})

	# メルカリはページ遷移に時間がかかるため、待つ
	# アクセス先の負荷軽減も兼ねる
	sleep(10)

	# 判定
	html = session.page_source
	# puts html
	if words[:keyword_short].any? { |t| html.include?(t) }
		# 在庫なし
		:res_short
	elsif words[:keyword_stock].any? { |t| html.include?(t) }
	  	# 在庫あり
	  	:res_stock
	elsif words[:keyword_not_found].any? { |t| html.include?(t) }
	  	# ページが存在しない
	  	:res_not_found
	else
	  	# 条件に一致なし
	  	:res_error
	end

end

# ログオブジェクトを生成
timestamp = Time.now.strftime('%Y%m%d%H%M%S')
log = Logger.new(%(./log/#{File.basename(__FILE__)}_ #{timestamp }.log'))

# リストのシート名を引数で受け取り
sheet_name_data = ARGV[0]

# スプレッドシートのID
spreadsheet_id = '1SuFFSAAIoU_RZTQiFc9RcKfb5l64kqHL2UkG1ieVdC8'

# 結果出力ワード
res_word = {
	res_short: "×在庫なし",
	res_stock: "○在庫あり",
	res_not_found:  "ページなし",
	res_error: "エラー"
}

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

puts "========================"
puts "Google OAuth"
puts "========================"

service = Google::Apis::SheetsV4::SheetsService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

puts "========================"
puts "在庫ワード取得"
puts "========================"
keyword_list = {}
sheet_name_word_settings = "ワード設定"
range = %(#{sheet_name_word_settings}!A2:E50)
response = service.get_spreadsheet_values(spreadsheet_id, range)
response.values.each do |row|
	# pp row
	site_name = row[0]
	domain = row[1]
	keyword_short = row[2].nil? ? [] : row[2].split(",")
	keyword_stock = row[3].nil? ? [] : row[3].split(",")
	keyword_not_found = row[4].nil? ? [] : row[4].split(",")
	keyword_list[domain] = {
		keyword_short: keyword_short,
		keyword_stock: keyword_stock,
		keyword_not_found: keyword_not_found
	}
end
# pp keyword_list

puts "========================"
puts "Selenium セットアップ"
puts "========================"
options = Selenium::WebDriver::Chrome::Options.new
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.2 Safari/605.1.15'
options.add_argument("--user-agent=#{user_agent}")
options.add_argument('headless')
options.add_argument('window-size=950,800')
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--remote-debugging-port=9222')
session = Selenium::WebDriver.for :chrome, options: options
session.manage.timeouts.implicit_wait = 5 # 10秒待っても読み込まれない場合は、エラーが発生する

puts "========================"
puts "対象URLの取得"
puts "========================"
range = %('#{sheet_name_data}'!A:D)
# puts range
response = service.get_spreadsheet_values(spreadsheet_id, range)

puts "========================"
puts "在庫チェック開始"
puts "========================"
result_data = []
response.values.each_with_index do |row, idx|
	target_url = row[0]
	check_result = row[3]
	
	# URLが入力されていない、または、結果が空でない場合、スキップ
	# エラーは再試行
	if target_url.nil? || (!check_result.nil? && check_result != "エラー")
		result_data.push(check_result)
		next
	end

	# ドメイン判定
	domain = URI.parse(target_url).host

	# アクセス先の負荷軽減
	# sleep(1)

	begin
		# チェック実行
		puts %(【URL】 #{url})
		check_res = check_stock(session, target_url, keyword_list[domain])
		puts check_res
		result_data.push(res_word[check_res])
		puts %(→SUCCESS：#{res_word[check_res]})
	rescue => e
		# エラー
		result_data.push(res_word[:res_error])
		p e
		puts %(→：在庫チェック失敗)
		log.fatal(%(【在庫チェック失敗】URL：#{target_url}))
	end
	puts "------------------------"
end
session.quit

# pp result_data

puts "========================"
puts "結果の書き込み"
puts "========================"
data = Google::Apis::SheetsV4::ValueRange.new
data.major_dimension = 'COLUMNS'
data.values = [result_data]
range = %('#{sheet_name_data}'!D1:D#{result_data.count+1})
response = service.update_spreadsheet_value(spreadsheet_id, range, data, value_input_option: 'RAW')


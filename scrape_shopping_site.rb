# bundle exec ruby scrape_shopping_site.rb

# selenium-webdriverを取り込む
require 'selenium-webdriver'
# loggerライブラリを読み込み
require 'logger'

def check_stock(url,words)
	# ブラウザの指定(Chrome)
	# user_agent = [
	#     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.2 Safari/605.1.15',
	#     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15',
	#     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36'
	# ]
	options = Selenium::WebDriver::Chrome::Options.new
	user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.2 Safari/605.1.15'
	options.add_argument("--user-agent=#{user_agent}")
	session = Selenium::WebDriver.for :chrome, options: options

	# 10秒待っても読み込まれない場合は、エラーが発生する
	session.manage.timeouts.implicit_wait = 10
	# ページ遷移する
	session.navigate.to "https://item.rakuten.co.jp/orbis-shop/r4908064080609/"

	# ページのタイトルを出力する
	puts session.title

	# 5秒遅延(処理が早すぎてページ遷移前にスクリーンショットされてしまうため)
	# sleep(1)

	if session.page_source.include?("商品をかごに追加")
		puts "SUCCESS"
	else
		puts "FAIL"
	end
	# puts session.page_source

	# ブラウザを終了
	session.quit
end

# ログオブジェクトを生成
timestamp = Time.now.strftime('%Y%m%d%H%M%S')
log = Logger.new(%(./log/#{File.basename(__FILE__)}_ #{timestamp }.log'))
log.level = Logger::ERROR
# 各ログレベルのログメッセージを'/tmp/rubyflie.log'に出力
log.debug('*debug log')
log.info('*info log')
log.warn('*warn log')
log.error('*error log')
log.fatal('*fatal log')
log.unknown('*unknown log')
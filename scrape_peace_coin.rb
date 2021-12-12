# bundle exec ruby scrape_test_selenium.rb

# selenium-webdriverを取り込む
require 'selenium-webdriver'

# ブラウザの指定(Chrome)
session = Selenium::WebDriver.for :chrome
# 10秒待っても読み込まれない場合は、エラーが発生する
session.manage.timeouts.implicit_wait = 10

# ページ遷移する
session.navigate.to "https://wallet.a-d.systems"

email = "info@hagukumu.co.jp"
password = "Hagukumu8996"

# session.find_element(:xpath, '//*form[2]/div[1]/input').send_keys email
# session.find_element(:xpath, '//*form[2]/div[2]/input').send_keys password
# session.find_element(:xpath, '//*form[2]/button').click
session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div[1]/div[2]/form/div[1]/input').send_keys email
session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div[1]/div[2]/form/div[2]/input').send_keys password
session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div[1]/div[2]/form/button').click

# ログイン中
sleep(5)

session.navigate.to "https://wallet.a-d.systems/admin/report"

# 遷移中
sleep(5)

session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[1]/div[3]/select').send_keys "11月"

sleep(5)

puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[1]/th[1]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[1]/td[1]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[1]/th[2]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[1]/td[2]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[2]/th[1]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[2]/td[1]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[2]/th[2]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[2]/td[2]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[3]/th[1]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[3]/td[1]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[3]/th[2]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[3]/td[2]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[4]/th[1]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[4]/td[1]').text
puts "=================="
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[4]/th[2]').text
puts session.find_element(:xpath, '//*[@id="__layout"]/div/div[1]/div/div[2]/div/table/tr[4]/td[2]').text
puts "=================="

# ブラウザを終了
session.quit
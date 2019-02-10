require 'rails_helper'

RSpec.feature "Tests", type: :system do
  # セッション(ウインドウ)を切り替える
  def switch_session(session)
    session.switch_to_window(session.current_window)
  end

  # セッション(ウインドウ)を閉じる
  def close_session(session)
    session.current_window.close
  end

  it "test", js: true do
    # セッションの場合は、visitの引数は完全なURLを渡す必要がある 
    url = "http://localhost:3000"

    session1 = Capybara::Session.new(:selenium_chrome)
    session1.visit url

    session2 = Capybara::Session.new(:selenium_chrome)
    session2.visit url

    msg1 = "これはセッション１こめ"
    session1.fill_in "content", with: msg1
    session1.click_on "submit_btn"
    expect(session1.has_content?(msg1)).to be_truthy
    expect(session2.has_content?(msg1)).to be_truthy

    msg2 = "これはセッション２こめ"
    session2.fill_in "content", with: msg2
    session2.click_on "submit_btn"
    expect(session2.has_content?(msg2)).to be_truthy
    expect(session1.has_content?(msg2)).to be_truthy

    switch_session(session2)
    switch_session(session1)

    close_session(session1)
    close_session(session2)
  end
end

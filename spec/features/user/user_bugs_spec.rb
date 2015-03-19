# filename: user_bugs_spec.rb

describe 'User Dashboard Bugs', type: :feature, sauce: sauce_labs do
  before do
    sign_in_user(ENV['User_Email'], ENV['User_Password'])
  end

  it 'Researcher signs in, creates a participant, assigns a group membership ' \
     'and sees correct calculation of end date' do
    click_on 'Participants'
    expect(page).to have_content 'Participants'
    click_on 'New'
    expect(page).to have_content 'New Participant'

    fill_in 'participant_study_id', with: 'Tests'
    fill_in 'participant_email', with: 'test@test.com'
    fill_in 'participant_phone_number', with: ENV['Participant_Phone_Number']
    select 'Email', from: 'participant_contact_preference'
    click_on 'Create'
    expect(page).to have_content 'Participant was successfully created.'

    click_on 'Assign New Group'
    expect(page).to have_content 'Assigning New Group to Participant'

    select 'Group 1', from: 'membership_group_id'
    fill_in 'membership_start_date',
            with: Date.today.prev_day.strftime('%Y-%m-%d')
    next_year = Date.today + 365
    fill_in 'membership_end_date', with: next_year.strftime('%Y-%m-%d')
    weeks_later = today + 56
    expect(page).to have_content 'Standard number of weeks: 8, Projected End ' \
                                 'Date from today: ' \
                                 "#{weeks_later.strftime('%-m/%-d/%Y')}"

    click_on 'Assign'
    expect(page).to have_content 'Group was successfully assigned'

    expect(page).to have_content 'Study Id: Tests'

    expect(page).to have_content 'Group: Group 1'

    expect(page).to have_content 'Membership Status: Active'
  end
end

require 'selenium-webdriver'
require 'rspec/expectations'
include RSpec::Matchers
require 'uuid'
require 'fileutils'

describe 'Researcher signs in,' do
  before do
    @download_dir = File.join(Dir.pwd, UUID.new.generate)
    FileUtils.mkdir_p @download_dir

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = @download_dir
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'text/csv'
    profile['pdfjs.disabled'] = true
    @driver = Selenium::WebDriver.for :firefox, profile: profile

    @driver.get "#{ENV['Base_URL']}/users/sign_in"
    @driver.find_element(id: 'user_email').send_keys(ENV['Researcher_Email'])
    @driver.find_element(id: 'user_password').send_keys(ENV['Researcher_Passw' \
                                                        'ord'])
    @driver.find_element(css: '.btn.btn-default').submit
  end

  after do
    @driver.quit
    FileUtils.rm_rf @download_dir
  end

  it 'navigates to CSV reports, and does not receive exception' do
    @driver.get "#{ENV['Base_URL']}/think_feel_do_dashboard/reports"
    download_link = @driver.find_elements(class: 'list-group-item')[12]
    download_link.click

    download_link = @driver.find_elements(class: 'list-group-item')[13]
    download_link.click

    files = Dir.glob("#{@download_dir}/**")
    files.count.should be == 2

    sorted_files = files.sort_by { |file| File.mtime(file) }
    File.size(sorted_files.last).should be > 0
  end
end

# filename: learn_spec.rb

require_relative '../../../spec/spec_helper'
require_relative '../../../spec/configure_cloud'

describe 'Active participant in group 1 is signed in and navigates to LEARN,', type: :feature, sauce: sauce_labs do
  before(:each) do
    visit ENV['Base_URL'] + '/participants/sign_in'
    within('#new_participant') do
      fill_in 'participant_email', with: ENV['Participant_Email']
      fill_in 'participant_password', with: ENV['Participant_Password']
    end

    click_on 'Sign in'
    expect(page).to have_content 'Signed in successfully'

    visit ENV['Base_URL'] + '/navigator/contexts/LEARN'
    expect(page).to have_content 'Lessons'
  end

  # tests
  it 'sees list opened to this week and is able to collapse list' do
    expect(page).to have_content 'Week 1'

    expect(page).to have_content 'Do - Awareness Introduction'

    today = Date.today
    click_on "Week 1 · #{today.strftime('%b %e')}"
    expect(page).to_not have_content 'Do - Awareness Introduction'
  end

  it 'reads Lesson 1' do
    expect(page).to have_content 'Week 1'

    click_on 'Do - Awareness Introduction'
    expect(page).to have_content 'This is just the beginning...'

    click_on 'Finish'
    today = Date.today
    expect(page).to have_content 'Read on ' + today.strftime('%b %e')

    expect(page).to have_content 'Printable'

    visit ENV['Base_URL']
    expect(page).to have_content 'read a Lesson: Do - Awareness Introduction'
  end

  it 'prints a read lesson' do
    expect(page).to have_content 'Week 1'

    today = Date.today
    expect(page).to have_content 'Read on ' + today.strftime('%b %e')

    click_on 'Printable'
    expect(page).to have_content 'Print'

    expect(page).to have_content 'Return to Lessons'

    click_on 'Return to Lessons'
    expect(page).to have_content 'Week 1'
  end
end

# filename: coach_patients_spec.rb

require_relative '../../../spec/spec_helper'
require_relative '../../../spec/configure_cloud'

# tests
describe 'Coach signs in and navigates to Patient Dashboard of Group 1', type: :feature, sauce: sauce_labs do
  before(:each) do
    visit ENV['Base_URL'] + '/users/sign_in'
    within('#new_user') do
      fill_in 'user_email', with: ENV['Clinician_Email']
      fill_in 'user_password', with: ENV['Clinician_Password']
    end

    click_on 'Sign in'
    expect(page).to have_content 'Signed in successfully'

    click_on 'Arms'
    find('h1', text: 'Arms')

    click_on 'Arm 1'
    expect(page).to have_content 'Title: Arm 1'

    click_on 'Group 1'
    expect(page).to have_content 'Title: Group 1'

    click_on 'Patient Dashboard'
    expect(page).to have_css('h1', text: 'Group 1 Patient Dashboard')
  end

  it 'views a list of active participants assigned to the coach' do
    page.find('#patients')[:class].include?('table table-hover')
    expect(page).to have_content 'TFD-1111'
  end

  it 'views a list of inactive participants assigned to the coach' do
    page.find('.btn.btn-default', text: 'Inactive Patients').click
    expect(page).to have_content 'Inactive Status'
    expect(page).to have_content 'Completer'
  end

  it 'selects Discontinue to end active status of participant' do
    within('#patients', text: 'TFD-1111') do
      within('table#patients tr', text: 'TFD-Discontinue') do
        click_on 'Discontinue'
      end
    end

    page.accept_alert 'Are you sure you would like to end this study? You will not be able to undo this.'
    expect(page).to_not have_content 'TFD-Discontinue'

    click_on 'Inactive Patients'
    expect(page).to have_content 'TFD-Discontinue'
    within('#patients', text: 'TFD-Discontinue') do
      within('table#patients tr', text: 'TFD-Discontinue') do
        today = Date.today
        yesterday = today - 1
        expect(page).to have_content 'Discontinued ' + yesterday.strftime('%Y-%m-%d')
      end
    end
  end

  it 'selects Withdraw to end active status of participant' do
    within('#patients', text: 'TFD-1111') do
      within('table#patients tr', text: 'TFD-Withdraw') do
        click_on 'Terminate Access'
      end
    end

    page.accept_alert 'Are you sure you would like to terminate access to this membership? ' \
                        'This option should also be used before changing membership of the patient' \
                        ' to a different group or to completely revoke access to this membership. ' \
                        'You will not be able to undo this.'
    expect(page).to_not have_content 'TFD-Withdraw'

    click_on 'Inactive Patients'
    expect(page).to have_content 'TFD-Withdraw'
    within('#patients', text: 'TFD-Withdraw') do
      within('table#patients tr', text: 'TFD-Withdraw') do
        today = Date.today
        yesterday = today - 1
        expect(page).to have_content 'Withdrawn ' + yesterday.strftime('%Y-%m-%d')
      end
    end
  end

  it 'views patient report' do
    within('#patients', text: 'TFD-1111') do
      click_on 'TFD-1111'
    end

    expect(page).to have_content 'General Patient Info'

    expect(page).to have_content 'Started on: ' + Date.today.strftime('%b %-d')

    weeks_later = Date.today + 56
    expect(page).to have_content '8 weeks from the start date is: ' + weeks_later.strftime('%b %-d')

    expect(page).to have_content 'Status: Active · Currently in week 1'
  end

  it 'uses the table of contents in the patient report' do
    within('#patients', text: 'TFD-1111') do
      click_on 'TFD-1111'
    end

    expect(page).to have_content 'General Patient Info'

    within('.list-group') do
      find('a', text: 'Mood and Emotions Visualizations').click
      page.all('a', text: 'Mood')[1].click
      find('a', text: 'Feelings').click
      find('a', text: 'Logins').click
      find('a', text: 'Lessons').click
      find('a', text: 'Audio Access').click
      find('a', text: 'Activities - Future').click
      find('a', text: 'Activities - Past').click
      page.all('a', text: 'Thoughts')[1].click
      find('a', text: 'Messages').click
      find('a', text: 'Tasks').click
    end

    within('.list-group') do
      find('a', text: 'Activities visualization').click
    end

    expect(page).to have_content 'Daily Averages'

    click_on 'Patient Dashboard'
    expect(page).to have_content 'General Patient Info'

    within('.list-group') do
      find('a', text: 'Thoughts visualization').click
    end

    expect(page).to have_css('#ThoughtVizContainer')

    click_on 'Patient Dashboard'
    expect(page).to have_content 'General Patient Info'
  end

  it 'views Mood/Emotions viz' do
    within('#patients', text: 'TFD-1111') do
      click_on 'TFD-1111'
    end

    expect(page).to have_content 'General Patient Info'

    within('#viz-container.panel.panel-default') do
      expect(page).to have_content 'Mood'

      expect(page).to have_content 'Positive and Negative Emotions'

      today = Date.today
      one_week_ago = today - 6
      one_month_ago = today - 27
      expect(page).to have_content one_week_ago.strftime('%B %e, %Y') + ' / ' + today.strftime('%B %e, %Y')

      within('.btn-group') do
        find('.btn.btn-default', text: '28 day').click
      end

      expect(page).to have_content one_month_ago.strftime('%B %e, %Y') + ' / ' + today.strftime('%B %e, %Y')

      within('.btn-group') do
        find('.btn.btn-default', text: '7 Day').click
      end

      click_on 'Previous Period'
      one_week_ago_1 = today - 7
      two_weeks_ago = today - 13
      expect(page).to have_content two_weeks_ago.strftime('%B %e, %Y') + ' / ' + one_week_ago_1.strftime('%B %e, %Y')
    end
  end

  it 'views Activities viz' do
    within('#patients', text: 'TFD-1111') do
      click_on 'TFD-1111'
    end

    expect(page).to have_content 'General Patient Info'

    page.all(:link, 'Activities visualization')[1].click
    expect(page).to have_content 'Today'
    today = Date.today
    expect(page).to have_content 'Daily Averages for ' + today.strftime('%b %e, %Y')

    click_on 'Daily Summaries'
    expect(page).to have_content 'Average Accomplishment Discrepancy'

    starttime = Time.now - 3600
    endtime = Time.now
    within('.panel.panel-default', text: starttime.strftime('%-l %P') + ' - ' + endtime.strftime('%-l %P:') + ' Loving') do
      click_on starttime.strftime('%-l %P') + ' - ' + endtime.strftime('%-l %P:') + ' Loving'
      within('.panel-collapse.collapse.in') do
        expect(page).to have_content 'Predicted'

        click_on 'Edit'
        expect(page).to have_css('#activity_actual_accomplishment_intensity')
      end
    end

    click_on 'Previous Day'
    yesterday = today - 1
    expect(page).to have_content 'Daily Averages for ' + yesterday.strftime('%b %e, %Y')

    click_on 'Next Day'
    expect(page).to have_content 'Daily Averages for ' + today.strftime('%b %e, %Y')

    click_on 'Visualize'
    click_on 'Last 3 Days'
    if page.has_text? 'Notice! No activities were completed during this 3-day period.'
      expect(page).to_not have_content today.strftime('%A, %m/%e')

    else
      expect(page).to have_content today.strftime('%A, %m/%e')
    end

    click_on 'Day'
    expect(page).to have_css('#datepicker')
  end

  it 'views Thoughts viz' do
    within('#patients', text: 'TFD-1111') do
      click_on 'TFD-1111'
    end

    expect(page).to have_content 'General Patient Info'

    within('.list-group') do
      find(:link, 'Thoughts visualization').click
    end

    page.find('#ThoughtVizContainer')
  end
end

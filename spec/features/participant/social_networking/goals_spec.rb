# filename: goals_spec.rb

describe 'Active pt in social arm signs in, navigates to ACHIEVE tool,',
         type: :feature, sauce: sauce_labs do
  before do
    sign_in_pt(ENV['Participant_Email'], ENV['Participant_Password'])
    visit "#{ENV['Base_URL']}/navigator/contexts/ACHIEVE"
  end

  it 'creates a goal' do
    click_on '+ add a goal'
    fill_in 'new-goal-description', with: 'eat a whole pizza'
    choose '8 weeks (end of study)'
    click_on 'Save'
    page.should have_css('.list-group-item.ng-scope', text: 'due yesterday')
    find('.list-group-item.ng-scope', text: 'eat a whole pizza')

    visit ENV['Base_URL']
    find_feed_item('Created a Goal: eat a whole pizza')
    within('.list-group-item.ng-scope',
           text: 'Created a Goal: eat a whole pizza') do
      click_on 'More'

      end_of_study = Date.today + 4
      expect(page).to have_content 'due ' \
                                   "#{end_of_study.strftime('%b. %e, %Y')}" \
                                   ' at 12:00AM'
    end
  end

  it 'completes a goal' do
    within('.list-group-item.ng-scope', text: 'p1 alpha') do
      click_on 'Complete'
    end

    page.accept_alert 'Are you sure you would like to mark this goal as ' \
                      'complete? This action cannot be undone.'
    page.should have_css('.list-group-item-success', text: 'p1 alpha')
    click_on 'Completed'
    expect(page).to_not have_content 'p1 gamma'

    expect(page).to have_content 'p1 alpha'

    visit ENV['Base_URL']
    find_feed_item('Completed a Goal: p1 alpha')
    expect(page).to have_content 'Completed a Goal: p1 alpha'
  end

  it 'deletes a goal' do
    find('.list-group-item.ng-scope',
         text: 'p1 gamma').find('.btn.btn-link.delete.ng-scope').click
    page.accept_alert 'Are you sure you would like to delete this goal? This ' \
                      'action cannot be undone.'
    expect(page).to_not have_content 'p1 gamma'

    click_on 'Deleted'
    expect(page).to_not have_content 'p1 alpha'

    expect(page).to have_content 'p1 gamma'
  end
end

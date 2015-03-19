# filename: content_author_slideshows_spec.rb

describe 'Content Author signs in and navigate to Slideshows tool',
         type: :feature, sauce: sauce_labs do
  before do
    sign_in_user(ENV['Content_Author_Email'], ENV['Content_Author_Password'])

    click_on 'Arms'
    find('h1', text: 'Arms')

    click_on 'Arm 1'
    expect(page).to have_content 'Title: Arm 1'

    click_on 'Manage Content'
    click_on 'Slideshows'
    expect(page).to have_content 'Listing Slideshows'
  end

  it 'creates a slideshow' do
    click_on 'New'
    expect(page).to have_content 'New Slideshow'

    fill_in 'slideshow_title', with: 'Test slideshow'
    click_on 'Create'
    expect(page).to have_content 'Successfully created slideshow'

    expect(page).to have_content 'Test slideshow'
  end

  it 'updates slideshow' do
    click_on 'Home Intro'
    expect(page).to have_content 'Slideshow'

    expect(page).to have_content 'Home Intro'

    expect(page).to have_content 'Anchors'

    page.all('a', text: 'Edit')[0].click
    expect(page).to have_content 'Edit Slideshow'

    fill_in 'slideshow_title', with: 'Home Introduction 123'
    click_on 'Update'
    expect(page).to have_content 'Successfully updated slideshow'

    click_on 'Home Introduction 123'
    expect(page).to have_content 'Slideshow'

    expect(page).to have_content 'Home Introduction 123'

    expect(page).to have_content 'Anchors'

    page.all('a', text: 'Edit')[0].click
    expect(page).to have_content 'Edit Slideshow'

    fill_in 'slideshow_title', with: 'Home Intro'
    click_on 'Update'
    expect(page).to have_content 'Successfully updated slideshow'
  end

  it 'destroys slideshow' do
    click_on 'Test slideshow'
    click_on 'Delete'
    page.accept_alert 'Are you sure?'
    expect(page).to_not have_content 'Test slideshow'
  end

  it 'uses breadcrumbs to return home' do
    click_on 'Arm'
    within('.breadcrumb') do
      click_on 'Arms'
    end

    expect(page).to have_content 'Arm 2'

    within('.breadcrumb') do
      click_on 'Home'
    end

    expect(page).to have_content 'Arms'
  end
end

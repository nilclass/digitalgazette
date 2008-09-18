require File.dirname(__FILE__) + '/../test_helper'

class PageSharingTest < Test::Unit::TestCase

  fixtures :pages, :users, :groups, :memberships, :user_participations

  def setup
  end

  def test_share_page_with_owner
    user = users(:kangaroo)
    group = groups(:animals)
    
    page = Page.create(:title => 'fun fun', :user => user, :share_with => group, :access => :admin)
    assert page.valid?, 'page should be valid: %s' % page.errors.full_messages.to_s
    assert group.may?(:admin, page), 'group be able to admin group'

    assert_nothing_raised do 
      user.share_page_with!(page, "animals", :message => 'hey you', :grant_access => :view)
    end

    assert group.may?(:admin, page), 'group should still be able to admin group'
  end

  def test_add_page
    user = users(:kangaroo)
    page = nil
    assert_nothing_raised do
      page = Page.create!(:title => 'fun fun')
    end

    page.add(user, :access => :edit)
    
    # sadly, page.users is not updated yet.    
    assert !page.users.include?(user), 'it would be nice if we could do this'

    assert_nothing_raised do
      page.save!
    end
    assert page.users.include?(user), 'page.users should be updated'

    assert_raises PermissionDenied do 
      user.may!(:admin, page)
    end 
  end
  
  def test_page_update
    page = pages(:wiki)
    user = users(:blue)
    page.add(user, :access => :admin)
    page.save!

    assert page.user_participations.size > 1
    page.user_participations.each do |up|
      up.update_attribute(:viewed, true)
    end

    user.updated(page)

    page = Page.find(page.id)
    page.user_participations.each do |up|
      assert_equal(false, up.viewed, 'should not be viewed') unless up.user == user
    end
  end

  protected
  
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Page.create(defaults.merge(options))
  end
  
end

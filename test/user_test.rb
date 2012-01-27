require 'helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :email
  should validate_presence_of :first_name
  should validate_presence_of :last_name
  should validate_presence_of :role_id
  should validate_presence_of :username
  
  should belong_to :role
  should have_many :permission_users
  should have_many :permissions
  
  context "With an existing user" do
    setup do
      Factory(:normal_user)
    end
    
    should validate_uniqueness_of :email
    should validate_uniqueness_of :username
  end
  
  context "A user instance" do
    should "have a name attribute that returns the full name" do
      user = User.new
      
      user.stubs(:first_name).returns('Cal')
      user.stubs(:last_name).returns('Ripken')

      assert_equal "Cal Ripken", user.name
      assert_equal "Cal R.", user.small_name
    end
    
    should "have a default_path where this user will be sent upon login" do
      role = Role.new      
      role.stubs(:default_path).returns('/role-path')
      
      user = User.new
      
      user.stubs(:role).returns(role)
      assert_equal '/role-path', user.default_path
      
      user.stubs(:role).returns(nil)
      assert_equal '/', user.default_path
    end
    
    should "have an active? user flag" do
      user = User.new
      
      user.active = true      
      assert_equal true, user.active
      assert_equal true, user.active?
      
      user.active = false
      assert_equal false, user.active
      assert_equal false, user.active?
    end
    
    should "not allow updating of certain protected attributes" do
      user = Factory(:user, :first_name => 'Old', :last_name => 'Nombre')
      
      assert_equal false, user.new_record?
      
      assert_equal 0, user.created_by
      assert_equal 1, user.role_id
      assert_equal 'Old Nombre', user.name
      
      user.update_account_attributes({
        :created_by => 1,
        :first_name => 'New',
        :last_name => 'Name',
        :role_id => 5
      })
      
      assert_equal 0, user.created_by
      assert_equal 1, user.role_id
      assert_equal 'New Name', user.name
    end 
    
    should "create a user with password and authenticate them" do
      user = Factory.build(:user)
      
      user.password = 'abc123'
      user.password_confirmation = 'abc123'      
      assert_equal 'abc123', user.password
      
      assert user.save
      
      assert_equal true, user.authenticate('abc123')
      assert_equal false, user.authenticate('test123')
    end 
    
    should "be able to update a user without changing their password" do
      user = Factory(:user)
      
      assert_equal true, user.authenticate('abc123')
      
      assert user.update_attributes(:first_name => 'New', :password => '', :password_confirmation => '')
      
      assert_equal 'New', user.first_name
      assert_equal true, user.authenticate('abc123')
    end
    
    should "validate a password" do
      user = Factory.build(:user)
      assert_equal true, user.valid?
      
      user.password = ''
      user.password_confirmation = ''      
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password can't be blank")
      
      user.password = 'abc'
      user.password_confirmation = 'abc'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password is not a valid password. Please enter at least 4 letters or numbers.")
      
      user.password = 'abc456'
      user.password_confirmation = 'abc123'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password does not match the confirmation password.")
    end
    
    should "get and set permission keys" do
      role = Factory(:role, :name => 'New Role')
      
      user = Factory.build(:plain_user)      
      user.role_id = role.id
            
      play = Permission.create(:name => 'Play', :key => 'play', :description => 'Just a test')
      run = Permission.create(:name => 'run', :key => 'run', :description => 'Just a test')
      shoot = Permission.create(:name => 'shoot', :key => 'shoot', :description => 'Just a test')
      
      user.permission_keys = %w( run play )
      assert_equal 2, user.permission_keys.length
      
      assert_equal true, user.permission?(:run)
      assert_equal true, user.has(:run)
      assert_equal true, user.run?
      
      assert_equal true, user.permission?(:play)
      assert_equal true, user.has(:play)
      assert_equal true, user.play?
      
      assert_equal false, user.permission?(:shoot)
      assert_equal false, user.has(:shoot)
      assert_equal false, user.shoot?
      
      assert_raises NoMethodError do
        user.bad_call_without_question_mark
      end
      
      assert user.save
      
      user.permission_keys = %w( run play shoot )
      user.save
      
      assert_equal true, user.permission?(:run)
      assert_equal true, user.has(:run)
      assert_equal true, user.run?
      
      assert_equal true, user.permission?(:play)
      assert_equal true, user.has(:play)
      assert_equal true, user.play?
      
      assert_equal true, user.permission?(:shoot)
      assert_equal true, user.has(:shoot)
      assert_equal true, user.shoot?
    end
  end
end
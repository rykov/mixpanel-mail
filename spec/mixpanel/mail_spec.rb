require 'spec_helper'

describe Mixpanel::Mail do
  TOKEN, CAMPAIGN = 'abcd123', 'my-email'

  it 'should intialize token & campaign' do
    lambda {
      mail = mp_mail
      mail.params['token'].should eq(TOKEN)
      mail.params['campaign'].should eq(CAMPAIGN)
    }.should_not raise_exception
  end

  describe 'options grooming' do
    it 'should filter out bad options' do
      mp_option_check('bad', 'woot' => nil)
    end

    it 'should recognize "type" option' do
      mp_option_check('type', {
        'text' => 'text',
        'html' => nil,
        'bad_bad' => nil
      })
    end
    
    it 'should recognize "click_tracking" option' do
      mp_option_check('click_tracking', { 
        true => true,
        false => '0'
      })
    end
    
    it 'should recognize "properties" option' do
      example = { :hello => :world }
      mp_option_check('properties', {
        nil => nil,
        {}  => '{}',
        example => MultiJson.encode(example)
      })
    end
    
    it 'should recognize "redirect_host" option' do
      mp_option_check('redirect_host', {
        nil => nil, 'anything' => 'anything'
      })
    end
  end

private
  def mp_mail(options = {})
    ::Mixpanel::Mail.new(TOKEN, CAMPAIGN, options)
  end
  
  def mp_option_check(key, value_expectations = {})
    value_expectations.each do |value, expectation|
      mp_mail(key => value).params[key].should eq(expectation)
      mp_mail(key.to_sym => value).params[key].should eq(expectation)
    end
  end
end

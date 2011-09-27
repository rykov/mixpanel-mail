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

  describe 'add tracking' do
    it 'should make a simple request' do
      verify_request_with_options
    end

    it 'should make a request with "type" request' do
      verify_request_with_options(
        { :type  => 'text' },
        { 'type' => 'text' }
      )
    end

    it 'should make a request with "click_tracking" request' do
      verify_request_with_options(
        { :click_tracking  => false },
        { 'click_tracking' => '0' }
      )
    end

    it 'should make a request with "properties" request' do
      props = { :foo => 'bar' }
      verify_request_with_options(
        { :properties  => props },
        { 'properties' => MultiJson.encode(props) }
      )
    end

    it 'should make a request with "redirect_host" request' do
      verify_request_with_options(
        { :redirect_host  => 'http://www.google.com' },
        { 'redirect_host' => 'http://www.google.com' }
      )
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

  def verify_request_with_options(options = {}, expectations = {})
    stub_post
    mp_mail(options).add_tracking('my-dist-id', 'Hello World!')
    mp_mail.add_tracking('my-dist-id', 'Hello World!', options)
    a_post.with(:body => expectations.merge(
      'token' => TOKEN,
      'campaign' => CAMPAIGN,
      'distinct_id' => 'my-dist-id',
      'body' => 'Hello World!'
    )).should have_been_made.twice
  end
end

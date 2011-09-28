require 'spec_helper'
require 'logger'
require 'mail'
require 'action_mailer'
require 'action_mailer/mixpanel_interceptor'

describe ActionMailer::MixpanelInterceptor do
  MI = ActionMailer::MixpanelInterceptor
  TOKEN = 'abcd123'
  TO_ADDY = 'test@gemfury.com'
  HTML_BODY = '<h1>HTML</h1>'

  before do
    MI.token = TOKEN
    MI.logger = Logger.new($stdout)
  end

  describe '::delivering_email' do
    before do
      @mail = Mail::Message.new do
        to   TO_ADDY
        body 'Hello World!'
      end
    end

    it 'should ignore mails without any MP options' do
      MI.delivering_email(@mail)
      a_post.should_not have_been_made
    end

    ### Shared Examples for All Emails ###
    shared_examples_for 'all emails' do
      it 'should remove all Mixpanel headers' do
        MI.delivering_email(@mail)
        default_headers.keys do |key|
          @mail.header[key].should be_nil
        end
      end
    end

    ### Shared Examples for Emails for non-Mixpanel emails ###
    shared_examples_for 'ignored Mixpanel email' do
      it_should_behave_like 'all emails'
      it 'should not make a Mixpanel request' do
        MI.delivering_email(@mail)
        a_post.should_not have_been_made
      end
    end

    describe 'with MP headers without mp_campaign' do
      before do
        apply_headers(@mail, default_headers(:campaign => nil))
        @mail.html_part { body(HTML_BODY) }
      end

      it_should_behave_like 'ignored Mixpanel email'
    end

    describe 'with Mixpanel headers' do
      before do
        apply_headers(@mail, default_headers)
      end

      describe 'without HTML email part' do
        it_should_behave_like 'ignored Mixpanel email'
      end

      describe 'with HTML email part' do
        before do
          @mail.html_part { body(HTML_BODY) }
          stub_post
        end

        it_should_behave_like 'all emails'

        it 'should make a request to Mixpanel' do
          params = Mixpanel::Mail.new(TOKEN, default_params).params
          params['distinct_id'] = Digest::MD5.hexdigest(TO_ADDY)
          params['body'] = HTML_BODY

          verify_mixpanel_requests(params) do
            MI.delivering_email(@mail)
          end
        end
      end
    end
  end

private
  def apply_headers(mail, headers)
    headers.each { |k, v| mail.header[k] = v }
  end

  def default_headers(headers = {})
    out = {}
    default_params(headers).each do |key, value|
      out["mp_#{key}".to_sym] = value
    end
    out
  end

  def default_params(headers = {})
    { :campaign => 'my-test-campaign',
      :properties => { :foo => :bar },
      :redirect_host => 'mp.testhost.com',
      :type => 'text' }.merge(headers)
  end
end

unless defined?(ActionMailer)
  raise StandardError, "ActionMailer is not loaded"
end

require 'mixpanel-mail'
require 'digest/md5'

module ActionMailer
  class MixpanelInterceptor
    cattr_accessor :token
    cattr_accessor :campaign

    def self.delivering_email(mail)
      html = mail.html_part
      mp_id = Digest::MD5.hexdigest(mail.header['To'].to_s)

      begin
        mail.html_part = mp_mail.add_tracking(mp_id, html)
      rescue => e
        Rails.logger.warn("Failed to Mixpanel Mail: #{e}")
        mail.html_part = html
      end
    end

  private
    def self.mp_mail
      @mixpanel_mail ||= Mixpanel::Mail.new(token, campaign)
    end
  end
end
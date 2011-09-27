unless defined?(ActionMailer)
  raise StandardError, "ActionMailer is not loaded"
end

require 'mixpanel-mail'
require 'digest/md5'

module ActionMailer
  class MixpanelInterceptor
    cattr_accessor :token

    class << self
      def delivering_email(mail)
        # Skip Mixpanel if the campaign is not specified
        return unless mail.header['mp_campaign']

        # Skip Mixpanel if we don't have HTML
        html = mail.html_part ? mail.html_part.body : nil
        return unless html.present?

        # Convert header options to mixpanel options
        opts = ::Mixpanel::Mail::OPTIONS.inject({}) do |sum, key|
          if value = pop_mp_header(mail, key)
            sum[key] = value
          end
          sum
        end

        # Generate email distinct_id for Mixpanel
        id = Digest::MD5.hexdigest(mail.header['To'].to_s)

        begin
          mail.html_part.body = mp_mail.add_tracking(id, html, opts)
        rescue => e
          Rails.logger.warn("Failed to Mixpanelize Mail: #{e}")
          mail.html_part.body = html
        end
      end

    private
      def mp_mail
        @mixpanel_mail ||= Mixpanel::Mail.new(token, 'default')
      end

      def pop_mp_header(mail, key)
        header_key = "mp_#{key}"
        value = mail.header[header_key]
        mail.header[header_key] = nil if value
        value
      end
    end
  end
end
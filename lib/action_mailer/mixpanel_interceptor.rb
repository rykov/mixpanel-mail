unless defined?(ActionMailer)
  raise StandardError, "ActionMailer is not loaded"
end

require 'mixpanel-mail'
require 'digest/md5'

module ActionMailer
  class MixpanelInterceptor
    cattr_accessor :token, :logger
    self.logger = Rails.logger if defined?(Rails)

    class << self
      def activate!(token)
        self.token = token
        ::ActionMailer::Base.register_interceptor(self)
      end

      def delivering_email(mail)
        # Remove all the Mixpanel headers from the email
        opts = ::Mixpanel::Mail::OPTIONS.inject({}) do |sum, key|
          if field = pop_mp_header(mail, key)
            sum[key] = field.value
          end
          sum
        end

        # Skip Mixpanel if the campaign is not specified
        return unless opts['campaign']

        # Skip Mixpanel if we don't have HTML
        html = mail.html_part ? mail.html_part.decoded : nil
        return unless html.present?

        # Generate email distinct_id for Mixpanel
        id = Digest::MD5.hexdigest(mail.header['To'].to_s)

        begin
          mail.html_part.body = mp_mail.add_tracking(id, html, opts)
        rescue => e
          mail.html_part.body = html
          logger.warn("Failed to Mixpanelize Mail: #{e}")
          logger.debug(e.backtrace.join("\n"))
        end
      end

    private
      def mp_mail
        @mixpanel_mail ||= Mixpanel::Mail.new(token)
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
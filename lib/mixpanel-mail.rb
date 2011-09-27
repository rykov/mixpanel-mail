require "mixpanel_mail/vendor/active_support"
require "mixpanel_mail/version"
require 'net/http'
require 'multi_json'
require 'uri'

#
# Adopted from http://mixpanel.com/api/docs/guides/email-analytics
#

module Mixpanel
  class Mail
    ENDPOINT = 'http://api.mixpanel.com/email'
    ENDPOINT_URI = URI.parse(ENDPOINT)
    OPTIONS = %w(campaign type properties redirect_host click_tracking)

    attr_accessor :params

    def initialize(token, campaign, options = {})
      @params = {}
      params['token'] = token
      params['campaign'] = campaign
      params.merge!(groom_options(options))
    end

    def add_tracking(distinct_id, body, options = {})
      p = params.dup()
      p['distinct_id'] = distinct_id
      p['body'] = body
      p.merge!(groom_options(options)) unless options.empty?
      response = Net::HTTP.post_form(::Mixpanel::Mail::ENDPOINT_URI, p)
      case response
      when Net::HTTPSuccess
          response.body
      else
          response.error!
      end
    end

  private
    def groom_options(options)
      opts = options.dup
      opts.stringify_keys!

      # Limit request to include only valid options
      opts.slice!(*OPTIONS)

      # Default type is HTML, so we only allow TEXT
      opts.delete('type') unless opts['type'] == 'text'

      # Marshal properties as JSON
      if opts['properties']
        opts['properties'] = MultiJson.encode(opts['properties'])
      end

      # Click tracking is enabled by default
      if opts['click_tracking'] == false
        opts['click_tracking'] = '0'
      end

      opts
    end
  end
end

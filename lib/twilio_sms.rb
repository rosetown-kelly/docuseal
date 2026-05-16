# frozen_string_literal: true

require 'json'
require 'net/http'

module TwilioSms
  DeliveryError = Class.new(StandardError)

  TWILIO_API_HOST = 'api.twilio.com'

  module_function

  def configured?
    account_sid.start_with?('AC') &&
      api_key_sid.present? &&
      api_key_secret.present? &&
      (phone_number.present? || messaging_service_sid.present?)
  end

  def deliver(to:, body:)
    raise DeliveryError, 'Twilio SMS is not configured.' unless configured?

    response = post_message(to:, body:)
    payload = parse_response(response)

    return payload if response.is_a?(Net::HTTPSuccess)

    message = payload['message'].presence || response.message

    raise DeliveryError, "Twilio SMS failed: #{message}"
  end

  def phone_number
    ENV.fetch('TWILIO_PHONE_NUMBER', '').gsub(/\s+/, '')
  end

  def messaging_service_sid
    ENV.fetch('TWILIO_MESSAGING_SERVICE_SID', '')
  end

  def account_sid
    ENV.fetch('TWILIO_ACCOUNT_SID', '')
  end

  def api_key_sid
    ENV.fetch('TWILIO_API_KEY_SID', '')
  end

  def api_key_secret
    ENV.fetch('TWILIO_API_KEY_SECRET', '')
  end

  def post_message(to:, body:)
    uri = URI::HTTPS.build(
      host: TWILIO_API_HOST,
      path: "/2010-04-01/Accounts/#{account_sid}/Messages.json"
    )

    request = Net::HTTP::Post.new(uri)
    request.basic_auth(api_key_sid, api_key_secret)
    request.set_form_data(message_params(to:, body:))

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  rescue SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout => e
    raise DeliveryError, "Twilio SMS failed: #{e.message}"
  end

  def message_params(to:, body:)
    {
      'To' => to,
      'Body' => body
    }.tap do |params|
      if messaging_service_sid.present?
        params['MessagingServiceSid'] = messaging_service_sid
      else
        params['From'] = phone_number
      end
    end
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    {}
  end
end

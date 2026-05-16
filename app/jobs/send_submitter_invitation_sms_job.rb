# frozen_string_literal: true

class SendSubmitterInvitationSmsJob
  include Sidekiq::Job

  sidekiq_options queue: :sms

  def perform(params = {})
    submitter = Submitter.find(params['submitter_id'])

    return if submitter.completed_at?
    return if submitter.declined_at?
    return if submitter.submission.archived_at?
    return if submitter.template&.archived_at?
    return if submitter.phone.blank?

    response = TwilioSms.deliver(to: submitter.phone, body: build_body(submitter))

    SubmissionEvent.create!(
      submitter:,
      event_type: 'send_sms',
      data: {
        phone: submitter.phone,
        twilio_sid: response['sid'],
        status: response['status'],
        segments: response['num_segments']
      }.compact_blank
    )

    submitter.sent_at ||= Time.current
    submitter.save!
  rescue TwilioSms::DeliveryError => e
    Rollbar.warning(e) if defined?(Rollbar)

    raise
  end

  private

  def build_body(submitter)
    I18n.with_locale(submitter.account.locale) do
      ReplaceEmailVariables.call(
        I18n.t(:submitter_invitation_sms_body_sign),
        submitter:,
        tracking_event_type: 'click_sms'
      )
    end
  end
end

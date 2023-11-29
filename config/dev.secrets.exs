import Config

# Configures Twilio in apps/phone
config :ex_twilio,
  # optional
  # workspace_sid: System.fetch_env!("TWILIO_WORKSPACE_SID"),
  account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN")

config :contact_center,
  twiml_dialer_app_sid: System.get_env("TWIML_DIALER_APP_SID"),
  twiml_queue_app_sid: System.get_env("TWIML_QUEUE_APP_SID"),
  twilio_phone_number: System.get_env("TWILIO_PHONE_NUMBER"),
  ngrok: System.get_env("NGROK")

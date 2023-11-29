defmodule ContactCenterWeb.Router do
  use ContactCenterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ContactCenterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ContactCenterWeb do
    pipe_through :browser

    live "/", PageLive.Index, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ContactCenterWeb do
    pipe_through :api
    # Enqueues the caller in a queue
    post "/enqueue", TwilioController, :enqueue
    # For queue Twilio devices to dial so as to answer an enqueued call
    post "/work_queue", TwilioController, :work_queue
    # To answer a call with some MP3 response
    post "/mp3", TwilioController, :mp3
    # To dial some number defined by as Twilio device
    post "/dial", TwilioController, :dial
    # To receive a call and have a conversation
    post "/receive_call", TwilioController, :receive_call
    # To behave like an IVR
    post "/ivr/welcome", TwilioController, :ivr_welcome
    post "/ivr/planets", TwilioController, :ivr_planets
    # To get SMS
    post "/sms", TwilioController, :sms
    post "/record", TwilioController, :record
    post "/webhook", TwilioController, :webhook
    # For receiving call statuses
    post "/status", TwilioController, :status
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:contact_center, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ContactCenterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

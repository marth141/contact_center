defmodule ContactCenterWeb.TwilioController do
  use ContactCenterWeb, :controller
  import Plug.Conn

  @doc """
  To play an MP3 to a caller
  """
  def mp3(conn, _params) do
    conn =
      conn
      |> put_resp_content_type("audio/mpeg")
      |> send_chunked(200)

    File.stream!("/home/kero/Videos/customer_care_voicemail_2.mp3", [], 128)
    |> Enum.into(conn)
  end

  @doc """
  For incoming call to forward to a Twilio device client
  """
  def receive_call(conn, %{"Caller" => caller}) do
    resp = Phone.receive_call(caller)

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  For behaving like an Interactive Voice Response (IVR)
  """
  def ivr_welcome(conn, _params) do
    resp = Phone.ivr_welcome(conn)

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  For behaving like an Interactive Voice Response (IVR)
  Sub-menu of TwilioController.ivr_welcome/2
  """
  def ivr_planets(conn, _params) do
    resp = Phone.ivr_planets(conn)

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  For dialing a number from the Device.connect parameters
  See app.js
  """
  def dial(conn, params) do
    number = params["dial"]
    resp = Phone.dial(number)

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  Enqueues a caller in a queue
  """
  def enqueue(conn, _params) do
    resp = Phone.enqueue()

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  For dialing a queue from the Device.connect parameters
  See app.js
  """
  def work_queue(conn, params) do
    number = params["dial"]
    resp = Phone.work_queue(number)

    conn
    |> put_resp_content_type("text/xml")
    |> text(resp)
  end

  @doc """
  For receiving sms
  """
  def sms(conn, _params) do
    IO.inspect(conn)

    conn
    |> put_resp_content_type("application/json")
    |> json(:ok)
  end

  def record(conn, _params) do
    IO.inspect(conn)

    # On completed recording message,
    # Make GET request for the recording URL
    # Using the response body, write that to a wav file.

    conn
    |> put_resp_content_type("application/json")
    |> json(:ok)
  end

  def webhook(conn, _params) do
    IO.inspect(conn)

    conn
    |> put_resp_content_type("application/json")
    |> json(:ok)
  end

  def status(conn, _params) do
    IO.inspect(conn)

    conn
    |> put_resp_content_type("application/json")
    |> json(:ok)
  end
end

defmodule Phone do
  @moduledoc """
  This is a top layer API for all of the phone features.
  """
  import ExTwiml

  def ngrok do
    Application.get_env(:contact_center, :ngrok)
  end

  def twilio_phone_number do
    Application.get_env(:contact_center, :twilio_phone_number)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Phone.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Fetches Twilio account sid from :ex_twilio
  """
  def fetch_account_sid() do
    Application.fetch_env!(:ex_twilio, :account_sid)
  end

  @doc """
  Fetches Twilio auth token from :ex_twilio
  """
  def fetch_auth_token() do
    Application.fetch_env!(:ex_twilio, :auth_token)
  end

  @doc """
  Fetches Twilio workspace sid from :ex_twilio
  """
  def fetch_workspace_sid() do
    Application.fetch_env!(:ex_twilio, :workspace_sid)
  end

  @doc """
  Provides an inbound and outbound capability token for a
  Twilio device acting as a standard phone
  See app.js
  """
  def fetch_dialer_access_token() do
    ExTwilio.Capability.new()
    |> ExTwilio.Capability.allow_client_incoming("jenny")
    |> ExTwilio.Capability.allow_client_outgoing(
      Application.get_env(:contact_center, :twiml_dialer_app_sid)
    )
    |> ExTwilio.Capability.token()
  end

  @doc """
  Provides a capability token for a Twilio device acting as a queue worker device
  See app.js
  """
  def fetch_queue_access_token() do
    ExTwilio.Capability.new()
    |> ExTwilio.Capability.allow_client_outgoing(
      Application.get_env(:contact_center, :twiml_queue_app_sid)
    )
    |> ExTwilio.Capability.token()
  end

  @doc """
  Returns Twiml to forward a call to a Twilio device client named "jenny"
  """
  def receive_call(caller) do
    twiml do
      dial callerId: caller do
        client("jenny")
      end
    end
  end

  @doc """
  Returns Twiml for dialing a specified number
  """
  def dial(number_to_dial) do
    twiml do
      dial(number_to_dial, callerId: twilio_phone_number())
    end
  end

  @doc """
  Returns Twiml for an Interactive Voice Response (IVR)
  """
  def ivr_welcome(conn) do\
    case conn.body_params["Digits"] do
      "1" ->
        twiml do
          say("To get to your extraction point, get on your bike and go down
          the street. Then Left down an alley. Avoid the police cars. Turn left
          into an unfinished housing development. Fly over the roadblock. Go
          passed the moon. Soon after you will see your mother ship.",
            loop: 3
          )

          pause(length: "3")
        end

      "2" ->
        twiml do
          redirect("#{ngrok()}/twilio/api/ivr/planets", method: "POST")
        end

      _ ->
        twiml do
          gather numDigits: "1" do
            say("Thanks for calling the E T Phone Home Service. Please press 1 for
            directions. Press 2 for a list of planets to call.")
            pause(length: "3")
          end

          redirect("#{ngrok()}/twilio/api/ivr/welcome", method: "POST")
        end
    end
  end

  @doc """
  Returns Twiml for an Interactive Voice Response (IVR)
  Sub-menu of Phone.ivr_welcome/1
  """
  def ivr_planets(conn) do
    case conn.body_params["Digits"] do
      "*" ->
        twiml do
          redirect("#{ngrok()}/twilio/api/ivr/welcome", method: "POST")
        end

      "1" ->
        enqueue()

      "2" ->
        twiml do
          say("Hello thank you for calling Broh doe As O G. We are not available good bye.")

          pause(length: "3")
        end

      "3" ->
        twiml do
          say(
            "Hello thank you for calling Duhgo bah. Yoda is being a swamp hick and won't answer the phone. May the force be with you."
          )

          pause(length: "3")
        end

      "4" ->
        twiml do
          say(
            "Hello thank you for calling oober asteroid. We know your location and will be there in 1 million years. Good bye."
          )

          pause(length: "3")
        end

      _ ->
        twiml do
          gather numDigits: "1" do
            say("To be put on hold in the support queue, press 1.
            To call the planet Broh doe As O G, press 2.
            To call the planet DuhGo bah, press 3.
            To call an oober asteroid to your location, press 4.
            To go back to the main menu, press the star key.")
            pause(length: "3")
            redirect("#{ngrok()}/twilio/api/ivr/planets", method: "POST")
          end
        end
    end
  end

  @doc """
  Returns Twiml to enqueue a call in a queue
  """
  def enqueue() do
    twiml do
      enqueue("support")
    end
  end

  @doc """
  Returns Twiml for a Twilio device to call a queue and connect with an enqueued caller
  """
  def work_queue(queue) do
    twiml do
      dial record: "record-from-answer",
           recordingStatusCallback: "#{ngrok()}/twilio/api/record",
           recordingStatusCallbackEvent: "in-progress completed absent" do
        queue(queue)
      end
    end
  end

  @doc """
  Gets a Twilio queue by its friendly name from Twilio
  """
  def get_twilio_queue_status_by_name(queue_name) do
    %{"queues" => queues} = TwilioApi.read_multiple_queue_resources()

    Enum.find(queues, fn queue -> queue["friendly_name"] == queue_name end)
  end
end

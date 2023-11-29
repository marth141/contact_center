defmodule TwilioApi do
  def get_call_resource(call_id) do
    Finch.build(
      :get,
      "https://api.twilio.com/2010-04-01/Accounts/#{account_sid()}/Calls/#{call_id}.json",
      [
        {"Authorization", "Basic #{auth_base64()}"}
      ]
    )
    |> Finch.request!(ContactCenter.Finch)
  end

  def get_call_resource_list() do
    %{body: body} = Finch.build(
      :get,
      "https://api.twilio.com/2010-04-01/Accounts/#{account_sid()}/Calls.json?PageSize=20",
      [
        {"Authorization", "Basic #{auth_base64()}"}
      ]
    )
    |> Finch.request!(ContactCenter.Finch)
    Jason.decode!(body)
  end

  def read_multiple_queue_resources() do
    with {:ok, %{body: body, status: 200}} <-
           Finch.build(
             :get,
             "https://api.twilio.com/2010-04-01/Accounts/#{account_sid()}/Queues.json?PageSize=20",
             [
               {"Authorization",
                "Basic #{auth_base64()}"}
             ]
           )
           |> Finch.request(ContactCenter.Finch),
         {:ok, queues} <- Jason.decode(body) do
      queues
    end
  end

  def read_multiple_member_resources(queue_sid) do
    with {:ok, %{body: body, status: 200}} <-
           Finch.build(
             :get,
             "https://api.twilio.com/2010-04-01/Accounts/#{account_sid()}/Queues/#{queue_sid}/Members.json",
             [
               {"Authorization",
                "Basic #{auth_base64()}"}
             ]
           )
           |> Finch.request(ContactCenter.Finch),
         {:ok, queues} <- Jason.decode(body) do
      queues
    end
  end

  def create_sink() do
    {:ok, %{body: body}} =
      Finch.build(
        :post,
        "https://events.twilio.com/v1/Sinks",
        [
          {"Authorization", "Basic #{auth_base64()}"},
          {"Content-Type", "application/x-www-form-urlencoded"}
        ],
        %{
          "Description" => "Test",
          "SinkConfiguration" => """
          {
            "destination": "#{Phone.ngrok()}/twilio/api/webhook",
            "method": "POST",
            "batch_events": false
          }
          """,
          "SinkType" => "webhook"
        }
        |> URI.encode_query()
        |> IO.inspect()
      )
      |> Finch.request(ContactCenter.Finch)

    body |> Jason.decode!()
  end

  def list_sinks() do
    {:ok, %{body: body}} =
      Finch.build(
        :get,
        "https://events.twilio.com/v1/Sinks",
        [
          {"Authorization", "Basic #{auth_base64()}"}
        ]
      )
      |> Finch.request(ContactCenter.Finch)

    body |> Jason.decode!()
  end

  def delete_sinks(sid) do
    Finch.build(
      :delete,
      "https://events.twilio.com/v1/Sinks/#{sid}",
      [
        {"Authorization", "Basic #{auth_base64()}"}
      ]
    )
    |> Finch.request(ContactCenter.Finch)
  end

  def delete_sinks() do
    TwilioApi.list_sinks()
    |> Map.get("sinks")
    |> Enum.each(fn sink -> TwilioApi.delete_sinks(sink["sid"]) end)
  end

  def create_subscription() do
    {:ok, %{body: body}} =
      Finch.build(
        :post,
        "https://events.twilio.com/v1/Subscriptions",
        [
          {"Authorization", "Basic #{auth_base64()}"},
          {"Content-Type", "application/x-www-form-urlencoded"}
        ],
        %{
          "Description" => "Test",
          "Types" => """
          {
            "type": "com.twilio.taskrouter.task-queue.entered"
          }
          """,
          "SinkSid" => "DGa137ce6c48915a358d3f9a173837c829"
        }
        |> URI.encode_query()
        |> IO.inspect()
      )
      |> Finch.request(ContactCenter.Finch)

    body |> Jason.decode!()
  end

  def list_event_types() do
    {:ok, %{body: body}} =
      Finch.build(
        :get,
        "https://events.twilio.com/v1/Types/com.twilio.taskrouter.task-queue.entered",
        [
          {"Authorization", "Basic #{auth_base64()}"}
        ]
      )
      |> Finch.request(ContactCenter.Finch)

    body |> Jason.decode!()
  end

  defp auth_base64() do
    Base.encode64("#{account_sid()}:#{auth_token()}")
  end

  defp account_sid() do
    Application.fetch_env!(:ex_twilio, :account_sid)
  end

  defp auth_token() do
    Application.fetch_env!(:ex_twilio, :auth_token)
  end
end

defmodule ContactCenter.Queue do
  @moduledoc """
  This is for setting up a queue for calls.
  """
  use GenServer, restart: :temporary

  @doc """
  Returns the state of a queue given its name
  """
  def read() do
    GenServer.call(__MODULE__, :read)
  end

  @doc """
  Refreshes the state of a given queue
  """
  def refresh_twilio_queue_status() do
    GenServer.call(__MODULE__, :refresh_twilio_queue_status)
  end

  @doc """
  Stops a given queue genserver pid
  """
  def stop_call() do
    GenServer.call(__MODULE__, :stop)
  end

  @doc """
  Stops a given queue genserver pid
  """
  def stop_cast() do
    GenServer.cast(__MODULE__, :stop)
  end

  defp schedule_poll(seconds) do
    Process.send_after(self(), :refresh_twilio_queue_status, :timer.seconds(seconds))
  end

  defp get_env() do
    Application.get_env(:contact_center, :env)
  end

  # GenServer Functions and Callbacks
  def start_link(friendly_name: friendly_name) do
    GenServer.start_link(__MODULE__, [friendly_name: friendly_name], name: __MODULE__)
  end

  @impl true
  def init(status) do
    {:ok, status, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, friendly_name: friendly_name) do
    case get_env() do
      :test ->
        {:noreply,
         %{
           "account_sid" => "",
           "average_wait_time" => 0,
           "current_size" => 0,
           "date_created" => "Wed, 01 Mar 2023 06:03:43 +0000",
           "date_updated" => "Wed, 01 Mar 2023 06:03:43 +0000",
           "friendly_name" => "support",
           "max_size" => 100,
           "sid" => "",
           "subresource_uris" => %{
             "members" =>
               ""
           },
           "uri" =>
             ""
         }
        }

      _ ->
        state = Phone.get_twilio_queue_status_by_name(friendly_name)
        schedule_poll(6)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:refresh_twilio_queue_status, state) do
    state = Phone.get_twilio_queue_status_by_name(state["friendly_name"])

    schedule_poll(6)
    {:noreply, state}
  end

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call(:refresh_twilio_queue_status, _from, state) do
    state = Phone.get_twilio_queue_status_by_name(state["friendly_name"])

    {:reply, state, state}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end
end

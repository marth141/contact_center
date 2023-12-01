defmodule ContactCenter.CallLogger do
  use GenServer, restart: :temporary

  @doc """
  Returns the state of the call logger
  """
  def read() do
    GenServer.call(__MODULE__, :read)
  end

  @doc """
  Refreshes the call logger.
  """
  def refresh() do
    GenServer.call(__MODULE__, :refresh_call_logs)
  end

  @doc """
  Sets the GenServer to repeat the refresh task
  """
  def schedule_call_log_refresh(seconds \\ 300) do
    Process.send_after(self(), :refresh_call_logs, :timer.seconds(seconds))
  end

  defp get_call_log() do
    with %{"calls" => calls} <- TwilioApi.get_call_resource_list() do
      calls
    else
      %{"status" => 401} -> []
    end
  end

  defp insert_call_logs_to_database(call_logs) do
    Enum.map(call_logs, fn call ->
      ContactCenter.CallLog.changeset(%ContactCenter.CallLog{}, call)
    end)
    |> Enum.map(fn changeset -> ContactCenter.Repo.insert(changeset) end)
  end

  defp get_env() do
    Application.get_env(:contact_center, :env)
  end

  # GenServer Functions and Callbacks
  def start_link(arguments) do
    GenServer.start_link(__MODULE__, arguments, name: __MODULE__)
  end

  @impl true
  def init(status) do
    {:ok, status, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, state) do
    case get_env() do
      :test ->
        {:noreply, []}

      _ ->
        schedule_call_log_refresh(10)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:refresh_call_logs, _state) do
    call_logs = get_call_log()

    insert_call_logs_to_database(call_logs)

    schedule_call_log_refresh()
    {:noreply, call_logs}
  end

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:refresh_call_logs, _from, _state) do
    call_logs = get_call_log()

    insert_call_logs_to_database(call_logs)

    {:reply, call_logs, call_logs}
  end
end

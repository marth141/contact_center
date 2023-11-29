defmodule ContactCenter.CallLogger do
  use GenServer, restart: :temporary

  @doc """
  Returns the state of the call logger
  """
  def read() do
    [{pid, _}] = Registry.lookup(Phone.MyRegistry, "call_logger")
    GenServer.call(pid, :read)
  end

  def refresh() do
    [{pid, _}] = Registry.lookup(Phone.MyRegistry, "call_logger")
    GenServer.call(pid, :refresh_call_logs)
  end

  @doc """
  Starts call logger GenServer
  """
  def start_call_logger() do
    name = {:via, Registry, {Phone.MyRegistry, "call_logger", []}}

    DynamicSupervisor.start_child(
      Phone.MyDynamicSupervisor,
      {__MODULE__, [name: name, status: []]}
    )
  end

  def schedule_poll(seconds \\ 300) do
    Process.send_after(self(), :refresh_call_logs, :timer.seconds(seconds))
  end

  # GenServer Callbacks
  def start_link(name: name, status: status) do
    GenServer.start_link(__MODULE__, status, name: name)
  end

  @impl true
  def init(status) do
    {:ok, status, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, state) do
    schedule_poll(10)
    {:noreply, state}
  end

  @impl true
  def handle_info(:refresh_call_logs, _state) do
    call_logs = get_call_log()

    insert_call_logs_to_database(call_logs)

    schedule_poll()
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

  defp get_call_log() do
    TwilioApi.get_call_resource_list()
    |> Map.get("calls")
  end

  defp insert_call_logs_to_database(call_logs) do
    Enum.map(call_logs, fn call ->
      ContactCenter.CallLog.changeset(%ContactCenter.CallLog{}, call)
    end)
    |> Enum.map(fn changeset -> ContactCenter.Repo.insert(changeset) end)
  end
end

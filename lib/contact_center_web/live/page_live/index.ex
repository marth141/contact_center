defmodule ContactCenterWeb.PageLive.Index do
  alias ContactCenter.Queue
  use ContactCenterWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    dialer_token = Phone.fetch_dialer_access_token()
    queue_token = Phone.fetch_queue_access_token()

    {:ok,
     socket
     |> assign(number: "+1")
     |> assign(queue: "support")
     |> assign(dialer_token: dialer_token)
     |> assign(queue_token: queue_token)
     |> assign(queue_status: get_queue_size())
     |> assign(buttons: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"])
    #  |> assign(call_logs: ContactCenter.CallLogger.read())
    }
  end

  @impl true
  def handle_event("validate", params, socket) do
    IO.inspect(params)
    socket = assign(socket, :number, params["number"])
    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    queue_status = get_queue_size()

    {:noreply,
     socket
     |> assign(:queue_status, queue_status)}
  end

  def get_queue_size() do
    %{"current_size" => current_size} = Queue.read()
    current_size
  end
end

defmodule ContactCenterWeb.PageLive.Index do
  alias ContactCenter.Queue
  use ContactCenterWeb, :live_view
  use Phoenix.Component
  import ContactCenterWeb.PageLive.DialerForm
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
      # TODO Flesh this out so that when Twilio webhook sends queue alert, we update queue status on page
      Phone.subscribe_to_queue("support")
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
     |> assign(buttons: dialer_buttons())
     |> assign(call_logs: get_call_logs())
    }
  end

  @impl true
  def handle_event("validate", params, socket) do
    socket = assign(socket, :number, params["number"])
    {:noreply, socket}
  end

  def handle_event("dial_button_press", params, socket) do
    number = socket.assigns.number
    socket = assign(socket, :number, number <> params["value"])
    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    queue_status = get_queue_size()

    {:noreply,
     socket
     |> assign(:queue_status, queue_status)}
  end

  def dialer_buttons() do
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
  end

  def get_call_logs() do
    query = from c in ContactCenter.CallLog, limit: 20
    ContactCenter.Repo.all(query)
  end

  def get_queue_size() do
    %{"current_size" => current_size} = Queue.read()
    current_size
  end

  attr :call_log, :map, required: true
  def call_log_item(assigns) do
    case assigns.call_log.direction do
      "inbound" ->
        ~H"""
        <li class="bg-gray-100 rounded-lg shadow-sm p-2 px-4 flex items-center space-x-2 justify-between" id={@call_log.sid}>
          <i class="hero-phone-arrow-down-left text-green-500" />
          <p>from: <%= @call_log.from %></p>
          <p>to: <%= @call_log.to %></p>
          <p>direction: <%= @call_log.direction %></p>
        </li>
        """
      "outbound-dial" ->
        ~H"""
        <li class="bg-gray-100 rounded-lg shadow-sm p-2 px-4 flex items-center space-x-2 justify-between" id={@call_log.sid}>
          <i class="hero-phone-arrow-up-right text-red-500" />
          <p>from: <%= @call_log.from %></p>
          <p>to: <%= @call_log.to %></p>
          <p>direction: <%= @call_log.direction %></p>
        </li>
        """
    end

  end
end

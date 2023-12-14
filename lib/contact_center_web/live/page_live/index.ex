defmodule ContactCenterWeb.PageLive.Index do
  alias ContactCenter.Queue
  use ContactCenterWeb, :live_view
  use Phoenix.Component
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
          <i class="hero-phone-arrow-down-left text-gray-700" />
          <p>from: <%= @call_log.from %></p>
          <p>to: <%= @call_log.to %></p>
          <p>direction: <%= @call_log.direction %></p>
        </li>
        """
      "outbound-dial" ->
        ~H"""
        <li class="bg-gray-100 rounded-lg shadow-sm p-2 px-4 flex items-center space-x-2 justify-between" id={@call_log.sid}>
          <i class="hero-phone-arrow-up-right text-gray-700" />
          <p>from: <%= @call_log.from %></p>
          <p>to: <%= @call_log.to %></p>
          <p>direction: <%= @call_log.direction %></p>
        </li>
        """
    end
  end

  def dialer_form(assigns) do
    ~H"""
    <div class="flex mt-4">
      <div class="flex flex-col space-y-10 min-w-[50px] items-center">
        <div id="dialer-log" phx-update="ignore">
          <div class="loading-status-dot group">
            <i class="flex hero-phone hover:animate-pulse"></i>
            <span class="dialer-status-tooltip">Dialer Starting</span>
          </div>
        </div>
        <div id="queue-log" phx-update="ignore">
          <div class="loading-status-dot group">
            <i class="flex hero-queue-list hover:animate-pulse"></i>
            <span class="queue-status-tooltip">Queue Starting</span>
          </div>
        </div>
      </div>
      <form name="dialer_form" phx-change="validate">
        <div class="flex flex-col max-w-[222px]">
          <div class="flex flex-row justify-center content-center">
            <input type="text" name="number" value={@number} class="rounded-xl"/>
          </div>
          <div id="dialer" phx-hook="Dialer" data-number={@number} data-token={@dialer_token} data-buttons={@buttons} class="flex justify-center space-x-16 my-4">
            <button type="button" id="dialer-call" class="green-phone-button">
              <i class="green-phone-icon"></i>
            </button>
            <button type="button" id="dialer-hangup" class="red-phone-button">
              <i class="red-phone-icon"></i>
            </button>
          </div>
          <div class="flex justify-center content-center mb-4">
            <div id="queue-status"><%= @queue_status %> callers in <%= @queue %> queue</div>
          </div>
          <div id="queue" phx-hook="Queue" data-token={@queue_token} data-queue={@queue} data-buttons={@buttons} class="flex justify-center content-center space-x-4 mb-8">
            <button type="button" id="queue-call" class="phone-button">
              Answer Queue
            </button>
            <button type="button" id="queue-hangup" class="phone-button">
              Hangup Queue
            </button>
          </div>
          <div class="flex gap-8 justify-center content-center">
            <div class="grid grid-cols-1 gap-8">
              <div class="grid grid-cols-3 gap-4 max-w-md">
                <%= for button <- @buttons do %>
                  <button id={"dial-" <> button} type="button" class="phone-button" value={button} phx-click="dial_button_press"><%= button %></button>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </form>
    </div>
    """
  end
end

defmodule ContactCenterWeb.PageLive.DialerForm do
  use Phoenix.Component

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

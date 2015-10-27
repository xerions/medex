defmodule Medex.Heartbeat do
  use GenServer

  def start_link(name, fun, interval) do
    GenServer.start_link(__MODULE__, [name, fun, interval * 1000])
  end

  
  # GenServer callbacks
  def init([name, fun, interval]) do
    timer = :erlang.send_after(0, self, :pulse)
    {:ok, %{timer: timer, name: name, fun: fun, interval: interval}}
  end

  def handle_info(:pulse, %{name: name, fun: fun, interval: interval, timer: timer} = state) do
    :erlang.cancel_timer(timer)
    :ets.update_element(Medex.Items, name, {4, fun.()})
    new_timer = :erlang.send_after(interval, self, :pulse)
    {:noreply, %{state | timer: new_timer}}
  end

  def terminate(_, _state) do
    :ok
  end
end

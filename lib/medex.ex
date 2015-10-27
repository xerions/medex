defmodule Medex do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Medex.Heartbeat, [])]

    {:ok, ip} = host |> String.to_char_list |> :inet.parse_address
    Plug.Adapters.Cowboy.http Medex.Router, [], port: port, ip: ip
    Medex.Items = :ets.new(Medex.Items, [:named_table, :public, read_concurrency: true])

    opts = [strategy: :simple_one_for_one, name: Medex.Supervisor]
    Supervisor.start_link(children, opts)
  end


  def register(name, fun, opts \\ []) do
    case info(name) do
      [{^name, _, _, _}] -> :already_declared
      _ -> 
        {:ok, pid} = Supervisor.start_child(Medex.Supervisor, [name, fun, interval(opts)])
        :ets.insert(Medex.Items, {name, pid, fun, :unknown})
    end
  end

  def unregister(name) do
   case info(name) do
     [{^name, pid, _, _}] ->
        Supervisor.terminate_child(Medex.Supervisor, pid)
        delete(name)
     _ -> :not_found
   end
  end

  def info(name), do: :ets.lookup(Medex.Items, name)

  def list, do: :ets.tab2list(Medex.Items)
  
  def delete(name), do: :ets.delete(Medex.Items, name)

  defp host, do: Application.get_env(:medex, :ip)
  defp port, do: Application.get_env(:medex, :port)
  defp interval(opts), do: opts[:interval] || 10
end

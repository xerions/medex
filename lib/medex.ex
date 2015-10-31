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
        consul_register(name, opts)
        {:ok, pid} = Supervisor.start_child(Medex.Supervisor, [name, fun, interval(opts)])
        :ets.insert(Medex.Items, {name, pid, fun, :unknown})
    end
  end

  def unregister(name) do
   case info(name) do
     [{^name, pid, _, _}] ->
        consul_unregister(name)
        Supervisor.terminate_child(Medex.Supervisor, pid)
        delete(name)
     _ -> :not_found
   end
  end

  def info(name), do: :ets.lookup(Medex.Items, name)

  def list, do: :ets.tab2list(Medex.Items)
  
  def delete(name), do: :ets.delete(Medex.Items, name)

  def update_status(name, status), 
    do: :ets.update_element(Medex.Items, name, {4, status})

  def use_consul, 
    do: Code.ensure_loaded?(Consul) and Application.get_env(:medex, :consul, false)

  defp host, do: Application.get_env(:medex, :ip) || "127.0.0.1"
  defp port, do: Application.get_env(:medex, :port) || 4000
  defp interval(opts), do: (opts[:interval] || Application.get_env :medex, :interval) || 10
  defp service_id(opts), do: opts[:service_id] || Application.get_env :medex, :service_id

  defp consul_register(name, opts) do
    if use_consul do
      body = %{
        "Name": name,
        "ServiceID": "#{service_id(opts)}",
        "TTL": "#{interval(opts)}s"}
      Consul.Agent.Check.register body
    end
  end

  defp consul_unregister(name) do
    if use_consul do
      Consul.Agent.Check.deregister name
    end
  end
end

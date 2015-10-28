defmodule MedexTest do
  use ExUnit.Case
  doctest Medex

  test "register and unregister" do
    Medex.register "db", fn -> :ok end
    Medex.register "api", fn -> :critical end
    assert :already_declared == Medex.register "api", fn -> :critical end
    :timer.sleep(100)
    assert 2 == length(Medex.list)
    assert [] == Medex.info "unknown"
    assert [{"db", _, _, :ok}] = Medex.info "db"
    assert [{"api", _, _, :critical}] = Medex.info "api"
    Medex.unregister "db"
    Medex.unregister "api"
    assert :not_found == Medex.unregister "api"
  end

  test "http check" do
    Medex.register "db", fn -> :ok end
    Medex.register "api", fn -> :critical end
    Medex.register "frontent", fn -> :warning end
    :timer.sleep(100)
    assert {:ok, {{_, 404, _}, _, _}} =  :httpc.request('http://localhost:4000/health/unknown')
    assert {:ok, {{_, 200, _}, _, _}} =  :httpc.request('http://localhost:4000/health/db')
    assert {:ok, {{_, 429, _}, _, _}} =  :httpc.request('http://localhost:4000/health/frontent')
    Medex.unregister "db"
    Medex.unregister "api"
    Medex.unregister "frontent"
  end
end

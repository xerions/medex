defmodule Medex.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/health/:name" do
    resp_code = case Medex.info(name) do
      [] -> translate_result(:not_found)
      [{^name, _, _, result}] -> result |> translate_result
    end
    conn |> send_resp(resp_code, "")
   end

  match _ do
    conn |> send_resp(404, "")
  end

  defp translate_result(:ok), do: 200
  defp translate_result(:passing), do: 200
  defp translate_result(:warning), do: 429
  defp translate_result(:critical), do: 500
  defp translate_result(:error), do: 500
  defp translate_result(:not_found), do: 404
  defp translate_result(:unknown), do: 404
  defp translate_result(_), do: 404
end

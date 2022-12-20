defmodule Cacher do
  def new(opts \\ []) do
    :ets.new(:items, [:set] ++ opts)
  end

  def clean(cacher) do
    :ets.delete(cacher)
  end

  def with_cache(cacher, key, calc) do
    case get_cached(cacher, :erlang.phash2(key)) do
      :error ->
        ret = calc.()
        cache(cacher, :erlang.phash2(key), ret)
        ret

      {:ok, val} ->
        val
    end
  end

  def get_cached(cacher, key) do
    case :ets.lookup(cacher, key) do
      [] -> :error
      [{^key, score}] -> {:ok, score}
    end
  end

  def cache(cacher, key, value) do
    :ets.insert(cacher, {key, value})
  end
end

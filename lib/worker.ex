defmodule Cachex.Worker do
  use GenServer

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end
  
  def read(pid, key) do
    GenServer.call(pid, {:read, key})
  end

  def write(pid, key, value) do
    GenServer.cast(pid, {:write, key, value})
  end

  def delete(pid, key) do
    GenServer.cast(pid, {:delete, key})
  end

  def exists?(pid, key) do
    GenServer.call(pid, {:exits, key})
  end

  def clear(pid) do
    GenServer.cast(pid, :flush)
  end

  def get_state(pid) do
    GenServer.call(pid, :stats)
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:read, key}, _from, state) do
    case Map.fetch(state, key) do
      {:ok, value} ->
        {:reply, value, state}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call(:stats, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:exits, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end

  def handle_cast({:write, key, value}, state) do
    new_state = update_map(state, key, value)
    {:noreply, new_state}
  end

  def handle_cast({:delete, key}, state) do
    new_state = remove_from_map(state, key)
    {:noreply, new_state}
  end

  def handle_cast(:flush, _state) do
    {:noreply, %{}}
  end

  ## Helper functions
  defp update_map(state, key, value) do
    case Map.has_key?(state, key) do
      true->
        Map.put(state, key, value)
      false->
        Map.put_new(state, key, value)
    end
  end

  defp remove_from_map(state, key) do
    case Map.has_key?(state, key) do
      true ->
        Map.delete(state, key)
      false ->
        IO.puts "key not present in map"
    end
  end
end
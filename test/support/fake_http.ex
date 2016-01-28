defmodule FakeHttp do
  use GenServer

  # Test pieces
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def set_callback(fun) when fun == nil or is_function(fun, 1) do
    GenServer.call(__MODULE__, {:set_callback, fun})
  end

  def handle_call({:set_callback, fun}, _from, _old_callback) do
    {:reply, :ok, fun}
  end
  def handle_call({:get, url}, _from, nil) do
    raise """
    No callback set, please call FakeHttp.set_callback/1 with a function that takes \
    at least one argument
    """
  end
  def handle_call({:get, url}, _from, callback) do
    {:reply, callback.(url), callback}
  end

  # HTTP interface
  def get(url) do
    GenServer.call(__MODULE__, {:get, url})
  end

end

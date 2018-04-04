defmodule NervesUartExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: NervesUartExample.Worker.start_link(arg)
      # {NervesUartExample.Worker, arg},
    ]

    spawn(fn -> uart_ini() end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesUartExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def uart_ini() do
    uart_opts = [speed: 9600, active: false]
    pids =
      Nerves.UART.enumerate() |> Enum.reduce(%{}, fn {k, _v}, _acc ->
        Logger.info "Open #{k}"
        {:ok, uart} = Nerves.UART.start_link()
        Logger.info "#{inspect uart}"
        _open = Nerves.UART.open(uart, k, uart_opts)
        Nerves.UART.write(uart, "Hello")
        [k, uart]
      end)
    uart_loop(pids)
  end

  defp uart_loop(pids) do
    [name, uart] = pids
    response = Nerves.UART.read(uart,3000)
    case response do
      {:ok, ""} ->
        Logger.info("timeout")
        uart_loop(pids)
      {:ok, msg} ->
        Logger.info("Recieved #{msg} de #{name}" )
        Nerves.UART.write(uart, "Hello Back")
        uart_loop(pids)
      {:error, _error} -> false
    end
  end
end

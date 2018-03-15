defmodule SortingHat do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SortingHat.Endpoint, []),
      worker(Mongo, [
        [
          name: :mongo,
          database: "phones",
          username: Application.get_env(:sorting_hat, :mongodb_username),
          password: Application.get_env(:sorting_hat, :mongodb_password),
          hostname: Application.get_env(:sorting_hat, :mongodb_hostname),
          port: Application.get_env(:sorting_hat, :mongodb_port)
        ]
      ]),
      Honeydew.queue_spec(:queue),
      Honeydew.worker_spec(:queue, SortingHat.Worker, num: 1)
    ]

    opts = [strategy: :one_for_one, name: SortingHat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SortingHat.Endpoint.config_change(changed, removed)
    :ok
  end
end

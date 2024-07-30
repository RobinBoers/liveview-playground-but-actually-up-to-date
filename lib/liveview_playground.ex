defmodule LiveviewPlayground do
  @moduledoc """
  Documentation for `LiveviewPlayground`.
  """

  @doc """
  Starts liveview playground

  All options are optional. They are:

    * `:router` - the Phoenix.Router module

    * `:endpoint` - the Phoenix.Endpoint module

    * `:script` - list of binaries that will be included as scripts on the layout <head>

  """
  def start(opts \\ []) do
    router = Keyword.get(opts, :router, LiveviewPlayground.Router)
    endpoint = Keyword.get(opts, :endpoint, LiveviewPlayground.Endpoint)
    scripts = Keyword.get(opts, :scripts, [])

    Application.put_env(:liveview_playground, endpoint,
      http: [ip: {127, 0, 0, 1}, port: 4000],
      server: true,
      live_view: [signing_salt: "aaaaaaaa"],
      secret_key_base: String.duplicate("a", 64),
      router: router,
      pubsub_server: LiveviewPlayground.PubSub
    )

    Application.put_env(:liveview_playground, :router, router)
    Application.put_env(:liveview_playground, :scripts, scripts)

    children = [
      {Phoenix.PubSub, name: LiveviewPlayground.PubSub},
      endpoint
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.sleep(:infinity)
  end
end

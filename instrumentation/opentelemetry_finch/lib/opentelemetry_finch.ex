defmodule OpentelemetryFinch do
  @moduledoc """
  OpentelemetryFinch uses [telemetry](https://hexdocs.pm/telemetry/) handlers to create `OpenTelemetry` spans.

  TODO list events
  Current events which are supported include

  ## Usage

  TODO add Finch in the example for consitency
  In your application start:

      def start(_type, _args) do
        OpentelemetryFinch.setup()

        children = [
          {Phoenix.PubSub, name: MyApp.PubSub},
          MyAppWeb.Endpoint
        ]

        opts = [strategy: :one_for_one, name: MyStore.Supervisor]
        Supervisor.start_link(children, opts)
      end

  """

  require OpenTelemetry.Tracer
  alias OpenTelemetry.Span

  @tracer_id :opentelemetry_finch

  # @typedoc "Setup options"
  # @type opts :: [endpoint_prefix()]

  # TODO decide what to do about configuring something similar to this
  # @typedoc "The endpoint prefix in your endpoint. Defaults to `[:phoenix, :endpoint]`"
  # @type endpoint_prefix :: {:endpoint_prefix, [atom()]}

  @doc """
  Initializes and configures the telemetry handlers.
  """
  @spec setup() :: :ok
  def setup() do
    attach_request_start_handler()
    attach_request_stop_handler()

    :ok
  end

  def request_transformer(req) do
    %{req | headers: :otel_propagator_text_map.inject(req.headers)}
  end

  # defp ensure_opts(opts), do: Keyword.merge(default_opts(), opts)

  # defp default_opts do
  #   # [endpoint_prefix: [:phoenix, :endpoint]]
  #   []
  # end

  @doc false
  def attach_request_start_handler() do
    :telemetry.attach(
      {__MODULE__, :request_start},
      [:finch, :connect, :start],
      &__MODULE__.handle_request_start/4,
      %{}
    )
  end

  @doc false
  def attach_request_stop_handler() do
    :telemetry.attach(
      {__MODULE__, :request_end},
      [:finch, :connect, :stop],
      &__MODULE__.handle_request_stop/4,
      %{}
    )
  end

  @doc false
  def handle_request_start(_event, _measurements, meta, _config) do
    attributes = [
      scheme: meta.scheme,
      host: meta.host,
      port: meta.port
      # path: meta.path,
      # method: meta.method
    ]

    IO.puts("handle request start!!!!!!!!!!!!!")

    OpentelemetryTelemetry.start_telemetry_span(@tracer_id, "#{meta.host}:#{meta.port}", meta, %{})
    |> Span.set_attributes(attributes)
  end

  @doc false
  def handle_request_stop(_event, _measurements, meta, _config) do
    # ensure the correct span is current and update the status
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

    IO.puts("handle request stop!!!!!!!!!!!!!")
    # TODO handle optional error
    # Span.set_attribute(ctx, :error, meta.error)

    # TODO check for meta.error
    # if conn.status >= 400 do
    #   Span.set_status(ctx, OpenTelemetry.status(:error, ""))
    # end

    # end the span
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
  end

  # @doc false
  # def handle_router_dispatch_start(_event, _measurements, meta, _config) do
  #   attributes = [
  #     "phoenix.plug": meta.plug,
  #     "phoenix.action": meta.plug_opts,
  #     "http.route": meta.route
  #   ]

  #   # Add more info that we now know about but don't close the span
  #   ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)
  #   Span.update_name(ctx, "#{meta.route}")
  #   Span.set_attributes(ctx, attributes)
  # end

  # @doc false
  # def handle_router_dispatch_exception(
  #       _event,
  #       _measurements,
  #       %{kind: kind, reason: reason, stacktrace: stacktrace} = meta,
  #       _config
  #     ) do
  #   ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

  #   {[reason: reason], attrs} =
  #     Reason.normalize(reason)
  #     |> Keyword.split([:reason])

  #   # try to normalize all errors to Elixir exceptions
  #   exception = Exception.normalize(kind, reason, stacktrace)

  #   # record exception and mark the span as errored
  #   Span.record_exception(ctx, exception, stacktrace, attrs)
  #   Span.set_status(ctx, OpenTelemetry.status(:error, ""))

  #   # do not close the span as endpoint stop will still be called with
  #   # more info, including the status code, which is nil at this stage
  # end
end

defmodule Phoenix.Slack do
  @moduledoc """
  The main feature provided by this module is the ability to set the HTML and/or
  text body of an message by rendering templates.

  It has been designed to integrate with Phoenix view, template and layout system.

  """

  import Phoenix.Slack.ChannelMessage

  defmacro __using__(opts) do
    unless view = Keyword.get(opts, :view) do
      raise ArgumentError, "no view was set, " <>
                           "you can set one with `use Phoenix.Slack, view: MyApp.SlackView`"
    end
    layout = Keyword.get(opts, :layout)
    quote bind_quoted: [view: view, layout: layout] do
      alias Phoenix.Slack.ChannelMessage
      import Phoenix.Slack.ChannelMessage
      import Phoenix.Slack, except: [render_body: 3]

      @view view
      @layout layout || false

      def render_body(message, template, assigns \\ %{}) do
        message
        |> put_new_layout(@layout)
        |> put_new_view(@view)
        |> Phoenix.Slack.render_body(template, assigns)
      end

      def local_text_template(), do: local_module_name() <> ".text"
      
      defp local_module_name() do
        __MODULE__
        |> Module.split
        |> List.last
        |> Macro.underscore
      end
    end
  end

  @doc """
  Renders the given `template` and `assigns` based on the `message`.

  Once the template is rendered the resulting string is stored on the message field `text_body`

  ## Arguments

    * `message` - the `Phoenix.Slack.ChannelMessage` struct

    * `template` - may be an atom or a string. If an atom, like `:welcome`, it
      will render both the HTML and text template and stores them respectively on
      the message. If the template is a string it must contain the extension too,
      like `welcome.text`.

    * `assigns` - a dictionnary with the assigns to be used in the view. Those
      assigns are merged and have higher order precedence than the message assigns.
      (`message.assigns`)

  ## Example

      defmodule Sample.UserSlack do
        use Phoenix.Slack, view: Sample.SlackView

        def welcome(user) do
          %ChannelMessage{}
          |> subject("Hello, Avengers!")
          |> render_body("welcome.text", %{username: user.message})
        end
      end

  The example above renders a template `welcome.text` from `Sample.SlackView` and
  stores the resulting string onto the text_body field of the message.
  (`message.text_body`)

  ## Layouts

  Templates are often rendered inside layouts. If you wish to do so you will have
  to specify which layout you want to use when using the `Phoenix.Slack` module.

      defmodule Sample.UserSlack do
        use Phoenix.Slack, view: Sample.SlackView, layout: {Sample.LayoutView, :message}

        def welcome(user) do
          %Slack{}
          |> from("tony@stark.com")
          |> to(user.message)
          |> subject("Hello, Avengers!")
          |> render_body("welcome.text", %{username: user.message})
        end
      end

  The example above will render the `welcome.text` template inside an
  `message.text` template specified in `Sample.LayoutView`. `put_layout/2` can be
  used to change the layout, similar to how `put_view/2` can be used to change
  the view.
  """
  def render_body(message, template, assigns) when is_atom(template) do
    message
    |> do_render_body(template_name(template, "text"), "text", assigns)
  end

  def render_body(message, template, assigns) when is_binary(template) do
    case Path.extname(template) do
      "." <> format ->
        do_render_body(message, template, format, assigns)
      "" ->
        raise "cannot render template #{inspect template} without format. Use an atom if you " <>
              "want to set both the text and text body."
    end
  end

  defp do_render_body(message, template, format, assigns) do
    assigns = Enum.into(assigns, %{})
    message =
      message
      |> put_private(:phoenix_template, template)
      |> prepare_assigns(assigns, format)

    view = Map.get(message.private, :phoenix_view) ||
            raise "a view module was not specified, set one with put_view/2"

    content = Phoenix.View.render_to_string(view, template, Map.put(message.assigns, :message, message))
    Map.put(message, :"#{format}_body", content)
  end

  @doc """
  Stores the layout for rendering.

  The layout must be a tuple, specifying the layout view and the layout
  name, or false. In case a previous layout is set, `put_layout` also
  accepts the layout name to be given as a string or as an atom. If a
  string, it must contain the format. Passing an atom means the layout
  format will be found at rendering time, similar to the template in
  `render_body/3`. It can also be set to `false`. In this case, no
  layout would be used.

  ## Examples

      iex> layout(message)
      false

      iex> message = put_layout message, {LayoutView, "message.text"}
      iex> layout(message)
      {LayoutView, "message.text"}

      iex> message = put_layout message, "message.text"
      iex> layout(message)
      {LayoutView, "message.text"}

      iex> message = put_layout message, :message
      iex> layout(message)
      {AppView, :message}
  """
  def put_layout(message, layout) do
    do_put_layout(message, layout)
  end

  defp do_put_layout(message, false) do
    put_private(message, :phoenix_layout, false)
  end

  defp do_put_layout(message, {mod, layout}) when is_atom(mod) do
    put_private(message, :phoenix_layout, {mod, layout})
  end

  defp do_put_layout(message, layout) when is_binary(layout) or is_atom(layout) do
    update_in message.private, fn private ->
      case Map.get(private, :phoenix_layout, false) do
        {mod, _} -> Map.put(private, :phoenix_layout, {mod, layout})
        false    -> raise "cannot use put_layout/2 with atom/binary when layout is false, use a tuple instead"
      end
    end
  end

  @doc """
  Stores the layout for rendering if one was not stored yet.
  """
  def put_new_layout(message, layout)
      when (is_tuple(layout) and tuple_size(layout) == 2) or layout == false do
    update_in message.private, &Map.put_new(&1, :phoenix_layout, layout)
  end

  @doc """
  Retrieves the current layout of an message.
  """
  def layout(message), do: message.private |> Map.get(:phoenix_layout, false)

  @doc """
  Stores the view for rendering.
  """
  def put_view(message, module) do
    put_private(message, :phoenix_view, module)
  end

  @doc """
  Stores the view for rendering if one was not stored yet.
  """
  def put_new_view(message, module) do
    update_in message.private, &Map.put_new(&1, :phoenix_view, module)
  end

  defp prepare_assigns(message, assigns, format) do
    layout =
      case layout(message, assigns, format) do
        {mod, layout} -> {mod, template_name(layout, format)}
        false -> false
      end

    update_in message.assigns,
              & &1 |> Map.merge(assigns) |> Map.put(:layout, layout)
  end

  defp layout(message, assigns, format) do
    if format in ["text"] do
      case Map.fetch(assigns, :layout) do
        {:ok, layout} -> layout
        :error -> layout(message)
      end
    else
      false
    end
  end

  defp template_name(name, format) when is_atom(name), do:
    Atom.to_string(name) <> "." <> format
  defp template_name(name, _format) when is_binary(name), do:
    name
end

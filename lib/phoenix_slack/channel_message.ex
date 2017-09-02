defmodule Phoenix.Slack.ChannelMessage do
  defstruct channel: nil,
            subject: nil,
            text_body: "",
            options: %{},
            assigns: %{},
            private: %{}

  @type channel :: String.t
  @type subject :: String.t
  @type text_body :: String.t
  @type options :: String.t

  @type t :: %__MODULE__{
    channel: channel | nil,
    subject: subject | nil,
    text_body: text_body,
    options: map,
    assigns: map,
    private: map,
  }

  @doc """
  """
  @spec channel(t, channel) :: t
  def channel(%__MODULE__{} = message, channel) do
    %{message | channel: channel}
  end

  @doc """
  """
  @spec subject(t, subject) :: t
  def subject(%__MODULE__{options: options} = message, subject) do
    %{message | options: Map.put(options, :subject, subject)}
  end

  @doc """
  """
  @spec options(t, options) :: t
  def options(%__MODULE__{} = message, options) do
    %{message | options: options}
  end


  @doc """
  """
  @spec text_body(t, text_body) :: t
  def text_body(%__MODULE__{} = message, text_body) do
    %{message | text_body: text_body}
  end

  @doc ~S"""
  Stores a new **private** key and value in the message.
  This store is meant to be for libraries/framework usage. The name should be
  specified as an atom, the value can be any term.
  """
  @spec put_private(t, atom, any) :: t
  def put_private(%__MODULE__{private: private} = message, key, value) when is_atom(key) do
    %{message | private: Map.put(private, key, value)}
  end

  @doc ~S"""
  Stores a new variable key and value in the message.
  This store is meant for variables used in templating. The name should be specified as an atom, the value can be any
  term.
  """
  @spec assign(t, atom, any) :: t
  def assign(%__MODULE__{assigns: assigns} = message, key, value) when is_atom(key) do
    %{message | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Uses Slacks link formatting.
  """
  @spec link(path: String.t, title: String.t) :: String.t
  def link(path: path, title: title) do
    "<#{path}|#{title}>"
  end

  def deliver(%Phoenix.Slack.ChannelMessage{channel: channel, text_body: text_body, options: options}) do
    Slack.Web.Chat.post_message(channel, text_body, options)
  end

end
defmodule Phoenix.SlackTest do
  use ExUnit.Case, async: true

  alias Phoenix.Slack.ChannelMessage
  import Phoenix.Slack.ChannelMessage
  import Phoenix.Slack

  defmodule MessageView do
    use Phoenix.View, root: "test/fixtures/templates", namespace: Slack.MessageView
  end

  defmodule LayoutView do
    use Phoenix.View, root: "test/fixtures/templates", namespace: Slack.LayoutView
  end

  defmodule TestMessage do
    use Phoenix.Slack, view: MessageView

    def welcome_local_text_template(), do: local_text_template()

    def welcome_text(), do: message() |> render_body("welcome.text", %{})

    def welcome_text_assigns(), do: message() |> render_body("welcome_assigns.text", %{name: "Tony"})

    def welcome_text_without_assigns(), do: message() |> render_body("welcome.text")

    def welcome_text_layout() do
      message()
      |> put_layout({LayoutView, "message.text"})
      |> render_body("welcome.text", %{})
    end

    def welcome_text_layout_without_assigns() do
      message()
      |> put_layout({LayoutView, "message.text"})
      |> render_body("welcome.text")
    end

    def welcome_text_layout_assigns() do
      message()
      |> put_layout({LayoutView, "message.text"})
      |> render_body("welcome_assigns.text", %{name: "Tony"})
    end

    def welcome(), do: message() |> render_body(:welcome, %{})

    def welcome_assigns(), do: message() |> render_body(:welcome_assigns, %{name: "Tony"})

    def welcome_layout() do
      message()
      |> put_layout({LayoutView, :message})
      |> render_body(:welcome, %{})
    end

    def welcome_layout_assigns() do
      message()
      |> put_layout({LayoutView, :message})
      |> render_body(:welcome_assigns, %{name: "Tony"})
    end

    def message() do
      %ChannelMessage{}
      |> text_body("tony@stark.com")
      |> subject("Welcome, Avengers!")
    end
  end

  defmodule TestMessageLayout do
    use Phoenix.Slack, view: MessageView, layout: {LayoutView, :message}

    def welcome() do
      %ChannelMessage{}
      |> text_body("tony@stark.com")
      |> subject("Welcome, Avengers!")
      |> render_body(:welcome, %{})
    end
  end

  setup_all do
    message =
      %ChannelMessage{}
      |> text_body("tony@stark.com")
      |> subject("Welcome, Avengers!")
      |> put_view(MessageView)
    {:ok, message: message}
  end


  test "render text body", %{message: message} do
    assert %ChannelMessage{text_body: "Welcome, Avengers!\n"} =
           render_body(message, "welcome.text", %{})
  end

  test "render text body with layout", %{message: message} do
    message = message |> put_layout({LayoutView, "message.text"})
    assert %ChannelMessage{text_body: "TEXT: Welcome, Avengers!\n\r\n"} =
           render_body(message, "welcome.text", %{})
  end

  test "render text body with assigns", %{message: message} do
    assert %ChannelMessage{text_body: "Welcome, Tony!\r\n"} =
           render_body(message, "welcome_assigns.text", %{name: "Tony"})
  end

  test "render text body with layout and assigns", %{message: message} do
    message = message |> put_layout({LayoutView, "message.text"})
    assert %ChannelMessage{text_body: "TEXT: Welcome, Tony!\r\n\r\n"} =
           render_body(message, "welcome_assigns.text", %{name: "Tony"})
  end

  test "macro: render text body" do
    assert %ChannelMessage{text_body: "Welcome, Avengers!\n"} =
           TestMessage.welcome_text()
  end

  test "macro: render text body with layout" do
    assert %ChannelMessage{text_body: "TEXT: Welcome, Avengers!\n\r\n"} =
           TestMessage.welcome_text_layout()
  end

  test "macro: render text body with layout without assigns" do
    assert %ChannelMessage{text_body: "TEXT: Welcome, Avengers!\n\r\n"} =
           TestMessage.welcome_text_layout_without_assigns()
  end

  test "macro: render text body without assigns" do
    assert %ChannelMessage{text_body: "Welcome, Avengers!\n"} =
           TestMessage.welcome_text_without_assigns()
  end

  test "macro: render text body with assigns" do
    assert %ChannelMessage{text_body: "Welcome, Tony!\r\n"} =
           TestMessage.welcome_text_assigns()
  end

  test "macro: render text body with layout and assigns" do
    assert %ChannelMessage{text_body: "TEXT: Welcome, Tony!\r\n\r\n"} =
           TestMessage.welcome_text_layout_assigns()
  end

  test "local_text_template" do
    assert TestMessage.welcome_local_text_template() == "test_message.text"
  end

  test "put_layout/2", %{message: message} do
    message =
      message
      |> put_layout({LayoutView, :wrong})
      |> put_layout(:message)
      |> render_body("welcome.text", %{})

    assert %ChannelMessage{text_body: "TEXT: Welcome, Avengers!\n\r\n"} =
           message
  end

  test "should raise if no view is set" do
    assert_raise ArgumentError, fn ->
      defmodule ErrorMessage do
        use Phoenix.Slack
      end
    end
  end

end

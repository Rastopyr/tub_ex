defmodule TubExTest.Channel do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @q "Elixir London"
  @channelId "UCy_6bBOVU8On2ZFU2vvSpbA"
  @key System.get_env("YOUTUBE_API_KEY")

  def channel_type_spec(%TubEx.Channel{}), do: true
  def channel_type_spec(_), do: false
  defp now, do: DateTime.to_unix(DateTime.utc_now())

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "channel detail" do
    use_cassette "get_channel" do
      HTTPoison.start
      {:ok, resp} = HTTPoison.get("#{TubEx.endpoint}/channels?id=#{@channelId}&key=#{@key}&part=snippet", [])
      %{ body: body, status_code: status } = resp;
      assert status == 200
      assert Poison.decode!(body) == TubEx.Channel.get(@channelId)
    end
  end

  test "negative detail channel" do
    use_cassette "negative_detail_channel" do
      HTTPoison.start
      { :error, %{ "error" => %{ "code" => code } } } = TubEx.Channel.get("#{now}", [key: nil])
      assert code == 400
    end
  end

  test "channel search" do
    use_cassette "search_by_query_channel" do
      HTTPoison.start
      query = TubEx.Utils.encode_body([
        key: @key,
        part: "snippet",
        maxResults: 20,
        type: "channel",
        q: @q
      ])

      {:ok, resp} = HTTPoison.get("#{TubEx.endpoint}/search?#{query}", [])
      %{ body: body, status_code: status } = resp
      response = Poison.decode!(body)

      { :ok, channels, page_info } = TubEx.Channel.search(@q)

      assert status == 200
      assert page_info["nextPageToken"] == response["nextPageToken"]
      assert page_info["prevPageToken"] == response["prevPageToken"]
      assert length(channels) === 20
      assert Enum.all?(channels, fn channel -> channel_type_spec(channel) end)
    end
  end

  test "negative channel search_by_query" do
    use_cassette "negative_search_by_query_channel" do
      HTTPoison.start
      query = [
        part: "123123"
      ]

      { :error, %{ "error" => %{ "code" => code } } } = TubEx.Channel.search(@q, query)

      assert code == 400
    end
  end

  test "raise channel parse" do
    use_cassette "raise_parse_channel" do
      HTTPoison.start

      assert_raise RuntimeError, fn -> TubEx.Channel.search("#{now}") end
    end
  end
end

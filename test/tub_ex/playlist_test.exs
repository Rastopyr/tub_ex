defmodule TubExTest.Playlist do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @q "Space"
  @playlistId "PLZRRxQcaEjA5tpoxlKeVnPKIvfD1IavPq"
  @key System.get_env("YOUTUBE_API_KEY")

  def playlist_type_spec(%TubEx.Playlist{}), do: true
  def playlist_type_spec(_), do: false
  defp now, do: DateTime.to_unix(DateTime.utc_now())

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "playlist detail" do
    use_cassette "get_playlist" do
      HTTPoison.start
      {:ok, resp} = HTTPoison.get("#{TubEx.endpoint}/playlists?id=#{@playlistId}&key=#{@key}&part=snippet", [])
      %{ body: body, status_code: status } = resp;
      %{ "items" => [ %{ "snippet" => item, "etag" => etag } ] } = Poison.decode!(body)
      { :ok, playlist } = TubEx.Playlist.get(@playlistId);

      expected = %TubEx.Playlist{
        etag: etag,
        title: item["title"],
        thumbnails: item["thumbnails"],
        published_at: item["publishedAt"],
        channel_title: item["channelTitle"],
        channel_id: item["channelId"],
        description: item["description"],
        playlist_id: @playlistId
      }

      assert status == 200
      assert playlist_type_spec playlist
      assert expected == playlist
    end
  end

  test "negative detail playlist" do
    use_cassette "negative_detail_playlist" do
      HTTPoison.start
      { :error, %{ "error" => %{ "code" => code } } } = TubEx.Playlist.get("#{now}", [key: nil])
      assert code == 400
    end
  end

  test "playlist search" do
    use_cassette "search_by_query_playlist" do
      HTTPoison.start
      query = TubEx.Utils.encode_body([
        key: @key,
        part: "snippet",
        maxResults: 20,
        type: "playlist",
        q: @q
      ])

      {:ok, resp} = HTTPoison.get("#{TubEx.endpoint}/search?#{query}", [])
      %{ body: body, status_code: status } = resp
      response = Poison.decode!(body)

      { :ok, playlists, page_info } = TubEx.Playlist.search(@q)

      assert status == 200
      assert page_info["nextPageToken"] == response["nextPageToken"]
      assert page_info["prevPageToken"] == response["prevPageToken"]
      assert length(playlists) === 20
      assert Enum.all?(playlists, fn playlist -> playlist_type_spec(playlist) end)
    end
  end

  test "negative playlist search_by_query" do
    use_cassette "negative_search_by_query_playlist" do
      HTTPoison.start
      query = [
        part: "123123"
      ]

      { :error, %{ "error" => %{ "code" => code } } } = TubEx.Playlist.search(@q, query)

      assert code == 400
    end
  end
end

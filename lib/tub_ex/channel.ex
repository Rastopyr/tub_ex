defmodule TubEx.Channel do
  @moduledoc """
    Provide access to the `/channels` are of YouTube API
  """

  @typedoc """
    Type that represents TubEx.Channel struct.
  """
  @type t :: %TubEx.Channel{
    title: charlist,
    etag: charlist,
    channel_id: charlist,
    description: charlist,
    published_at: charlist,
    thumbnails: map,
  }
  defstruct [
    title: nil,
    etag: nil,
    channel_id: nil,
    description: nil,
    published_at: nil,
    thumbnails: %{},
  ]

  @doc """
    Fetch contents details

    Example:
      iex> TubEx.Channel.get("_J4QPz52Sfo")
      { :ok, %TubEx.Channel{} }
  """
  @spec get(charlist) :: { atom, TubEx.Channel.t  }
  def get(channel_id, opts \\ []) do
    defaults = [key: TubEx.api_key, id: channel_id, part: "snippet"]

    case api_request("/channels", Keyword.merge(defaults, opts)) do
      {:ok, %{ "items" => [ %{ "snippet" => item, "etag" => etag } ] } } ->
        parse %{
          "etag" => etag,
          "snippet" => item,
          "id" => %{ "channelId" => channel_id }
        }
      err -> err
    end
  end

  @doc """
  Search channel from youtube via query.

  ## Examples

    ** Get channels by query: **
      iex> TubEx.Channel.search("The great debates")
      { :ok, [%TubEx.Channel{}, ...], meta_map }

    ** Custom query parameters: **
      iex> TubEx.Channel.search("The great debates", [
        paramKey: paramValue,
        ...
      ])
      { :ok, [%TubEx.Channel{}, ...], meta_map }
  """
  @spec search(charlist, Keyword.t) :: { atom, list(TubEx.Channel.t), map }
  def search(query, opts \\ []) do
    defaults = [
      key: TubEx.api_key,
      part: "snippet",
      maxResults: 20,
      q: query
    ]

    response = api_request("/search", Keyword.merge(defaults, opts))

    case response do
      {:ok, response} ->
        {:ok, Enum.map(response["items"], &parse!/1), page_info(response)}
      err -> err
    end
  end

  defp api_request(pathname, query) do
    TubEx.API.get(
      TubEx.endpoint <> pathname,
      Keyword.merge(query, [type: "channel"])
    )
  end

  defp page_info(response) do
    Map.merge(response["pageInfo"], %{
      "nextPageToken" => response["nextPageToken"],
      "prevPageToken" => response["prevPageToken"]
    })
  end

  defp parse!(body) do
    case parse(body) do
      {:ok, channel} -> channel
      {:error, body} ->
        raise "Parse error occured! #{Poison.Encoder.encode(body, %{})}"
    end
  end

  defp parse(%{"snippet" => snippet, "etag" => etag, "id" => %{"channelId" => channel_id}}) do
    {:ok,
      %TubEx.Channel{
        etag: etag,
        title: snippet["title"],
        thumbnails: snippet["thumbnails"],
        published_at: snippet["publishedAt"],
        description: snippet["description"],
        channel_id: channel_id
      }
    }
  end

  defp parse(body) do
    {:error, body}
  end
end

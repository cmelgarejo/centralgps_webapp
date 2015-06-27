defmodule CentralGPS.Repo.Utilities do
  alias Enum,   as: E
  alias String, as: S
  alias Tuple,  as: T
  alias CentralGPSWebApp.Endpoint

  @doc """
  Processes and returns a tuple with 2 maps, FOR LIST FUNCTIONS ON DB:
  _params : All the parameters that have been passed on to the controller as JSON
    mapped and checked against the filter_keys parameter of this function.
  headers: First, checks if the "Authorization" header is set, so we can
    authorize the request and then maps it to be available to as such for the
    caller
  """
  def list_auth_proc_headers_and__params(headers, _params, filter_keys \\ []) do
    headers = Enum.into(headers, %{}) |> objectify_map #Create a map of headers
    if !Map.has_key?(headers, :authorization),
      do: (raise ArgumentError, message: "missing: :authorization")
    _regex = ~r/^(?<tag>CentralGPS)\stoken=(?<token>.*).type=(?<type>.*)/
    auth = Regex.named_captures(_regex, headers.authorization)
    if auth == nil, do: auth = %{tag: nil, token: nil, type: nil}
    auth = objectify_map(auth)
    _params = objectify_map(_params)
    { offset, limit, search_column, search_phrase, sort_column, sort_order } =
      { 0, 0, nil, nil, nil, nil }
    if (Map.has_key? _params, :limit),  do: {limit, _params} = Map.pop(_params, :limit, nil)
    if (Map.has_key? _params, :offset), do: {offset, _params} = Map.pop(_params, :offset, nil)
    if (Map.has_key? _params, :search_column),  do: {search_column, _params} = Map.pop(_params, :search_column, nil)
    if (Map.has_key? _params, :search_phrase),  do: {search_phrase, _params} = Map.pop(_params, :search_phrase, nil)
    if (Map.has_key? _params, :sort_column),  do: {sort_column, _params} = Map.pop(_params, :sort_column, nil)
    if (Map.has_key? _params, :sort_order),  do: {sort_order, _params} = Map.pop(_params, :sort_order, nil)
    _params = Map.put(_params, :_z_limit, limit) |> Map.put(:_z_offset, offset)
      |> (Map.update :_z_offset, nil,   fn(v)->(if !is_integer(v), do: Integer.parse(v) |> elem(0), else: v) end)
      |> (Map.update :_z_limit, nil, fn(v)->(if !is_integer(v), do: Integer.parse(v) |> elem(0), else: v) end)
      |> Map.put(:_z_search_column, search_column) |> Map.put(:_z_search_phrase, search_phrase)
      |> Map.put(:_z_sort_column, sort_column) |> Map.put(:_z_sort_order, sort_order)
    _params = _params
      |> (Map.put :_the_app_name,
          (if Map.has_key?(headers,:"x-requested-with"),
            do: to_string(headers[:"x-requested-with"]),
            else: (if Map.has_key?(_params, :_the_app_name),
                    do: _params._the_app_name, else: nil)))
      |> (Map.put :_the_ip_port,
          (if Map.has_key?(headers,:"x-forwarded-for"),
            do: to_string(headers[:"x-forwarded-for"]),
            else: (if Map.has_key?(_params, :_the_ip_port),
                    do: _params._the_ip_port, else: nil)))
      |> (Map.put :_xtra_info, (if Map.has_key?(_params, :_xtra_info),
                                do: _params._xtra_info, else: nil))
    filter_keys = filter_keys ++ [ :_the_app_name, :_the_ip_port, :_xtra_info,
                    :_z_limit, :_z_offset, :_z_search_column, :_z_search_phrase,
                    :_z_sort_column, :_z_sort_order ]
    _params =  objectify_map(_params, filter_keys)
      |> (Map.put :_auth_token, auth.token)
      |> (Map.put :_auth_type,  auth.type)
    {headers, _params}
  end

  @doc """
  Processes and returns a tuple with 2 maps, FOR LIST FUNCTIONS ON DB:
  _params : All the parameters that have been passed on to the controller as JSON
    mapped and checked against the filter_keys parameter of this function.
  headers: First, checks if the "Authorization" header is set, so we can
    authorize the request and then maps it to be available to as such for the
    caller
  """
  def auth_proc_headers_and__params(headers, _params, filter_keys \\ []) do
    headers = Enum.into(headers, %{}) |> objectify_map #Create a map of headers
    if !Map.has_key?(headers, :authorization),
      do: (raise ArgumentError, message: "missing: :authorization")
    _regex = ~r/^(?<tag>CentralGPS)\stoken=(?<token>.*).type=(?<type>.*)/
    auth = Regex.named_captures(_regex, headers.authorization)
    if auth == nil, do: auth = %{tag: nil, token: nil, type: nil}
    auth = objectify_map(auth)
    _params = objectify_map(_params)
    _params = _params
      |> (Map.put :_the_app_name,
          (if Map.has_key?(headers,:"x-requested-with"),
            do: to_string(headers[:"x-requested-with"]),
            else: (if Map.has_key?(_params, :_the_app_name),
                    do: _params._the_app_name, else: nil)))
      |> (Map.put :_the_ip_port,
          (if Map.has_key?(headers,:"x-forwarded-for"),
            do: to_string(headers[:"x-forwarded-for"]),
            else: (if Map.has_key?(_params, :_the_ip_port),
                    do: _params._the_ip_port, else: nil)))
      |> (Map.put :_xtra_info, (if Map.has_key?(_params, :_xtra_info),
                                do: _params._xtra_info, else: nil))
    filter_keys = filter_keys ++ [ :_the_app_name, :_the_ip_port, :_xtra_info ]
    _params =  objectify_map(_params, filter_keys)
      |> (Map.put :_auth_token, auth.token)
      |> (Map.put :_auth_type,  auth.type)
    {headers, _params}
  end

  @doc """
  **CHECKPOINT METHODS ONLY**
  Processes and returns a tuple with 2 maps:
  params : All the parameters that have been passed on to the controller as JSON
    mapped and checked against the filter_keys parameter of this function.
  headers: First, checks if the "Authorization" header is set, so we can
    authorize the request and then maps it to be available to as such for the
    caller
  """
  def checkpoint_auth_proc_headers_and_params(headers, params, filter_keys \\ []) do
    headers = Enum.into(headers, %{}) |> objectify_map #Create a map of headers
    if !Map.has_key?(headers, :authorization),
      do: (raise ArgumentError, message: "missing: :authorization")
    _regex = ~r/^(?<tag>CentralGPS)\stoken=(?<token>.*).type=(?<type>.*)/
    auth = Regex.named_captures(_regex, headers.authorization)
    if auth == nil, do: auth = %{tag: nil, token: nil, type: nil}
    auth = objectify_map(auth)
    params =  objectify_map(params)
      |> objectify_map(filter_keys) # 2nd call to have atomized keys this round
      |> (Map.put :_auth_token, auth.token)
      |> (Map.drop [ :format ])
    if (Map.has_key? params,(:offset)) do
      {offset, params} = Map.pop(params, :offset, 0)
      Map.put params, :zzz_offset, offset
    end
    if (Map.has_key? params,(:limit)) do
      {limit, params} = Map.pop(params, :limit, 100)
      Map.put params, :zzzz_limit, limit
    end
    {headers, params}
  end

  @doc """
  Pretty prints any error you pass on to this func.

  ex  : exception object
  _env: __ENV__ object of the function
  vars: a map with all the vars you want to control. i.e: %{var1: var1}
  """
  def error_logger(ex, _env, vars \\ []) do
    require Logger
    env = Macro.Env.stacktrace(_env) |> hd
    Logger.error "[#{env |> elem 0}.#{env |> elem 1}]: #{inspect ex}
    file: #{env |> elem(3) |> hd |> elem (1)}
    line: #{env |> elem(3) |> tl |> hd |> elem(1)}
    vars: #{inspect vars}"
  end

  @doc """
  Makes any map that doesn't have atoms as keys to an atomized map, syntax sugar
  for OOProgramers :P

  Parameters:

  map:  The map that should be proccesed.

  filter_keys: (optional) keys that will filter the map and leave only those
  that match, in case ANY of the keys it's not in the processed map,
  the function will return [ArgumentError]

  """
  def objectify_map(map, filter_keys \\ []) when is_map(map) do
    try do
      if !(E.empty?filter_keys) do
        filter_keys = E.map(filter_keys, fn (k -> (if !is_atom(k),
                                                    do: S.to_atom(k),
                                                  else: k)) end)
        (for k <- filter_keys, !Map.has_key?(map,k), do:
          (raise ArgumentError, message: "missing: #{k}"))
        map = Map.take map, filter_keys
      end
      E.reduce map, %{}, fn({k,v}, m) -> Map.put m, (if !is_atom(k), do: S.to_atom(k), else: k), v end
    rescue
      e in _ ->
        error_logger e, __ENV__, %{filter_keys: filter_keys, map: map}
        raise e
    end
  end

  @doc """
  Validates and decodes a Base64 encoded string
  """
  def base64_decode(b64str) do
    try do
      case b64str do
        nil -> nil
        _   ->
          case Base.url_decode64(b64str) do
            {:ok, str} -> if (S.valid?str), do: str
            _          -> nil
          end
      end
    rescue
      e in _ ->
        error_logger e, __ENV__, %{b64str: b64str}
        raise e
    end
  end

  @doc """
  Encodes a string to Base64
  """
  def base64_encode(str) do
    try do
      if (S.valid?str), do: (Base.url_encode64 str), else: str
    rescue
      e in _ ->
        error_logger e, __ENV__, %{str: str}
        raise e
    end
  end

  @doc """
  Converts a result from Ecto.Adapters.SQL.query to a map %{} (JSON parseable)

  table: A Ecto table result (map) from Ecto.Adapters.SQL.query i.e:
  %{columns: ["col1", "col2", "col3"], command: :select, num_rows: 1,
    rows: [{1, "value1", nil}]}

  filter:  Contains a list of keys that should be used and taken if present
  (exclusively)
  """
  def table_to_map(table, filter \\ []) do
    try do
      if table.num_rows > 0 do
        result = (for r <- table.rows, do:
              E.zip((table.columns |> E.map &(S.to_atom &1)),T.to_list(r))
           |> E.into(%{}))
        {row_count, result} =
        {
          table.num_rows,
          result = (if (!E.empty?filter), do:
                      (for m <- result, do: Map.take(m, filter)), else: result)
        }
      else
        { 0, [] }
      end
    rescue
      e in _ ->
        error_logger e, __ENV__, %{table: table}
        raise e
    end
  end

  @doc """
  Returns a valid filename from a structure %Plug.Upload{}
  """
  def upload_file_name(plug) do
    Regex.replace(~r/[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/, plug.filename, "_")
  end

  @doc """
  Returns a boolean indicating if the passed %Plug.Upload{} structure has a
  valid mimetyped image in it.
  """
  def upload_is_image?(plug) do
    content_type = plug.content_type
    image_mimes = [ Plug.MIME.type("png"), Plug.MIME.type("jpg"),
      Plug.MIME.type("gif") ]
    Enum.find_index(image_mimes, fn(x) -> x == content_type end) != nil
  end

  @doc """
  Returns the static path where every static served file should be served
  """
  def _priv_static_path, do: Enum.join([Endpoint.config(:root), "priv/static"], "/")

  defp dest_dir(filename), do:
    Enum.join([_priv_static_path, (String.split(filename, "/") |> Enum.reverse |> tl |> Enum.reverse |> Enum.join "/")], "/")

  @doc """
  Gets a filename, a file (and an old_filename, if exists it will delete it)
  and saves said image to the relative directory the image filename provides
  """
  def save_image_base64(filename, file, old_filename \\ "") do
    try do
      if !is_nil(filename) do
        if (old_filename != ""), do: File.rm Enum.join([ _priv_static_path,  old_filename ], "/") #removes the old image
        if (!File.exists?dest_dir(filename)), do: File.mkdir_p dest_dir(filename)
        filename = Enum.join [ _priv_static_path, filename ], "/"
        File.write!filename, Base.url_decode64!(file)
      end
    rescue
      e in _ -> error_logger e, __ENV__, %{filename: filename, old_filename: old_filename, file: file}
      :error
    end
    :ok
  end

  @doc """
  Gets a file via HTTP and saves it to the location of the filename
  (concatenated with the _priv_static_path)
  """
  def get_image(url, filename) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    filename = Enum.join [ _priv_static_path, filename ], "/"
    File.write!filename, body
  end

end

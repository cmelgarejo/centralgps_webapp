defmodule CentralGPS.L10n do
  use Gettext, otp_app: :central_g_p_s_web_app

  @doc """

  """
  def l10n(lang, domain, id) do
    {_, msg} = lgettext(lang, domain, id)
    msg
  end

  @doc """
  This fn can be used only in :view's because usually phoenix_template is
  assigned after that.
  """
  def l10n(conn, id) do
    {headers, domain} = {conn.req_headers, conn.private.phoenix_template}
    lang = headers |> List.keyfind("accept-language", 0) |> elem(1) |> String.split(~r";|,|(q=([0-9]*\.[0-9]+|[0-9]+));?", trim: true) |> hd
    lang = Regex.run(~r/^[a-z]{2}/, lang)
    if (lang != nil), do: lang = lang |> hd
    {_, msg} = lgettext(lang, domain, id)
    msg
  end
end

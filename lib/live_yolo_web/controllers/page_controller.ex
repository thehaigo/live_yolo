defmodule LiveYoloWeb.PageController do
  use LiveYoloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

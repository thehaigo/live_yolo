defmodule LiveYoloWeb.PageLive do
  use LiveYoloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:upload_file, nil)
      |> assign(:clip_images, [])
      |> allow_upload(
        :image,
        accept: :any,
        chunk_size: 6400_000,
        progress: &handle_progress/3,
        auto_upload: true
      )
    }
  end

  def handle_progress(:image, _entry, socket) do
    {upload_file, mime} =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        {:ok, file} = File.read(path)

        {file, entry.client_type}
      end)
      |> List.first()

    {
      :noreply,
      socket
      |> assign(:upload_file, upload_file)
      |> push_event("draw", %{src: Base.encode64(upload_file), mime: mime})
    }
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("detect", _params, socket) do
    detection =
      LiveYolo.Worker.request_detection(LiveYolo.Worker, socket.assigns.upload_file)
      |> LiveYolo.Worker.await()

    {
      :noreply,
      socket
      |> assign(:detect, detection)
      |> push_event("detect", %{detect: detection})
    }
  end

  @impl true
  def handle_event("clip", _params, socket) do
    detection =
      LiveYolo.Worker.request_detection(LiveYolo.Worker, socket.assigns.upload_file)
      |> LiveYolo.Worker.await()

    {
      :noreply,
      socket
      |> assign(:detect, detection)
      |> push_event("clip", %{detect: detection})
    }
  end

  @impl true
  def handle_event("cliped", params, socket) do
    images =
      Enum.map(params, fn param ->
        %{label: param["label"], src: param["src"]}
      end)

    {:noreply, assign(socket, :clip_images, images)}
  end

  @impl true
  def handle_event("remove", _params, socket) do
    {
      :noreply,
      socket
      |> assign(upload_file: nil, detect: nil, clip_images: [])
      |> push_event("remove", %{})
    }
  end
end

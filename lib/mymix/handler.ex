defmodule Mymix.Handler do

	@moduledoc "Handles HTTP requests."

	@pages_path Path.expand("../../pages", __DIR__)

	alias Mymix.Conv, as: Conv
	alias Mymix.BearController
	import Mymix.Plugins, only: [rewrite_path: 1, log: 1, track: 1]

	import Mymix.Parser, only: [parse: 1]

	@doc "Transform the request into responce."
	def handle(request) do
		request
		|> parse
		|> rewrite_path
		|> log
		|> route
		|> track
		|> format_response
	end

	def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Mymix.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Mymix.PledgeController.index(conv)
  end

	def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
		sensor_data = Mymix.SensorServer.get_sensor_data()

    %{ conv | status: 200, resp_body: inspect sensor_data}
  end

	def route(%Conv{ method: "GET", path: "/kaboom" } = _conv) do
	  raise "Kaboom!"
	end

	def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
	  time |> String.to_integer |> :timer.sleep

	  %{ conv | status: 200, resp_body: "Awake!" }
	end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

	def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
		@pages_path
			|> Path.join(file <> ".html")
			|> File.read
			|> handle_file(conv)
	end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
  		BearController.create(conv, conv.params)
	end

	def route(%Conv{method: "GET", path: "/about"} = conv) do
		@pages_path
			|> Path.join("about.html")
			|> File.read
			|> handle_file(conv)
	end

	def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
		@pages_path
			|> Path.join("form.html")
			|> File.read
			|> handle_file(conv)
	end

	def route(%Conv{method: "GET", path: "/bears"} = conv) do
		BearController.index(conv)
	end

	def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
		Mymix.Api.BearController.index(conv)
	end

	def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
		params = Map.put(conv.params, "id", id)
  	BearController.show(conv, params)
	end

	def route(%Conv{path: path} = conv) do
  	%{ conv | status: 404, resp_body: "No #{path} here!" }
	end

	def handle_file({:ok, content}, conv) do
		%{ conv | status: 200, resp_body: content }
	end

	def handle_file({:error, :enoent}, conv) do
		%{ conv | status: 404, resp_body: "File not found!" }
	end

	def handle_file({:error, reason}, conv) do
		%{ conv | status: 500, resp_body: "File error #{reason}" }
	end

	def format_response(%Conv{} = conv) do
	    """
	    HTTP/1.1 #{Conv.full_status(conv)}\r
	    Content-Type: #{conv.resp_content_type}\r
	    Content-Length: #{String.length(conv.resp_body)}\r
	    \r
	    #{conv.resp_body}
	    """
	end
end

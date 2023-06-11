defmodule Mymix.Parser do

	alias Mymix.Conv, as: Conv 

	def parse(request) do
		[top, params_string] = String.split(request, "\r\n\r\n")

		[request_line | header_lines] = String.split(top, "\r\n")

		headers = parse_headers(header_lines, %{})

		params = parse_params(headers["Content-Type"], params_string)

  		[method, path, _] = String.split(request_line, " ")

  		%Conv{ 
  		   method: method, 
  		   path: path,
  		   params: params,
  		   headers: headers,
  		}
	end

	@doc """
	Parses the given param sstring of the form `key1=value1&key2=value2`
	into a map with corresponding keys aand values.

	## Examples
		iex> params_string = "name=Ballo&type=Brown"
		iex> Mymix.Parser.parse_params("application/x-www-form-urlencoded", params_string)
		%{"name" => "Ballo", "type" => "Brown"}
		iex> Mymix.Parser.parse_params("multipart/from-data", params_string)
		%{}
	"""
	def parse_params("application/x-www-form-urlencoded", params_string) do
		params_string |> String.trim |> URI.decode_query
	end

	def parse_params(_, _), do: %{}

	def parse_headers([h | t], headers) do
		[k, v] = String.split(h, ": ")
		headers = Map.put(headers, k, v)
		parse_headers(t, headers)
	end

	def parse_headers([], headers), do: headers
end
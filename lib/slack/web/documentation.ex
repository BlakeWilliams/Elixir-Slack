defmodule Slack.Web.Documentation do
  @moduledoc false

  defstruct [
    :endpoint,
    :module,
    :function,
    :desc,
    :required_params,
    :optional_params,
    :errors,
    :raw
  ]

  def new(documentation, file_name) do
    endpoint = String.replace(file_name, ".json", "")

    {module_name, function_name} = parse_endpoint(endpoint)

    %__MODULE__{
      module: module_name,
      endpoint: endpoint,
      function: function_name |> Macro.underscore() |> String.to_atom(),
      desc: documentation["desc"],
      required_params: get_required_params(documentation),
      optional_params: get_optional_params(documentation),
      errors: documentation["errors"],
      raw: documentation
    }
  end

  def arguments(documentation) do
    documentation.required_params
    |> Enum.map(&Macro.var(&1, nil))
  end

  def arguments_with_values(documentation) do
    documentation
    |> arguments
    |> Enum.reduce([], fn var = {arg, _, _}, acc ->
      [{arg, var} | acc]
    end)
  end

  def to_doc_string(documentation) do
    Enum.join(
      [
        documentation.desc,
        required_params_docs(documentation),
        optional_params_docs(documentation),
        errors_docs(documentation)
      ],
      "\n"
    )
  end

  defp required_params_docs(%__MODULE__{required_params: []}), do: ""

  defp required_params_docs(documentation) do
    get_param_docs_for(documentation, :required_params, "Required Params")
  end

  defp optional_params_docs(%__MODULE__{optional_params: []}), do: ""

  defp optional_params_docs(documentation) do
    get_param_docs_for(documentation, :optional_params, "Optional Params")
  end

  defp get_param_docs_for(documentation, field, title) do
    Map.get(documentation, field)
    |> Enum.reduce("\n#{title}\n", fn param, doc ->
      meta = get_in(documentation.raw, ["args", to_string(param)])
      doc <> "* `#{param}` - #{meta["desc"]} #{example(meta)}\n"
    end)
  end

  def example(%{"example" => example}) do
    "ex: `#{example}`"
  end

  def example(_meta), do: ""

  defp errors_docs(%__MODULE__{errors: nil}), do: ""

  defp errors_docs(%__MODULE__{errors: errors}) do
    errors
    |> Enum.reduce("\nErrors the API can return:\n", fn {error, desc}, doc ->
      doc <> "* `#{error}` - #{desc}\n"
    end)
  end

  defp get_required_params(json), do: get_params_with_required(json, true)
  defp get_optional_params(json), do: get_params_with_required(json, false)

  defp get_params_with_required(%{"args" => args}, required) do
    args
    |> Enum.filter(fn {_, meta} ->
      if required do
        meta["required"]
      else
        !meta["required"]
      end
    end)
    |> Enum.map(fn {name, _meta} ->
      name |> String.to_atom()
    end)
  end

  defp get_params_with_required(_json, _required) do
    []
  end

  @spec parse_endpoint(String.t()) :: {String.t(), String.t()}
  defp parse_endpoint(endpoint) do
    {module_name, function_name} =
      endpoint
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.find_index(&(&1 == "."))
      |> (&String.split_at(endpoint, -&1)).()

    {String.replace_suffix(module_name, ".", ""), function_name}
  end
end

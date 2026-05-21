defmodule Deputy.Validation do
  @moduledoc """
  Shared input validation helpers used by resource modules before issuing
  API requests.
  """

  alias Deputy.Error.ValidationError

  @doc """
  Verify that every key in `required_fields` is present in `attrs`.

  Accepts either atom or string keys in `attrs` and matches against atom
  field names. Returns `:ok` if all required fields are present, or
  `{:error, %ValidationError{}}` for the first missing field.

  ## Examples

      iex> Deputy.Validation.required_fields(%{name: "foo", id: 1}, [:name, :id])
      :ok

      iex> Deputy.Validation.required_fields(%{"name" => "foo"}, [:name])
      :ok

      iex> {:error, %Deputy.Error.ValidationError{field: :id}} =
      ...>   Deputy.Validation.required_fields(%{name: "foo"}, [:name, :id])

  """
  @spec required_fields(map(), [atom()]) :: :ok | {:error, ValidationError.t()}
  def required_fields(attrs, required_fields) when is_map(attrs) and is_list(required_fields) do
    case Enum.find(required_fields, &missing?(attrs, &1)) do
      nil ->
        :ok

      field ->
        {:error,
         %ValidationError{
           message: "missing required field: #{field}",
           field: field,
           value: nil
         }}
    end
  end

  defp missing?(attrs, field) do
    not (Map.has_key?(attrs, field) or Map.has_key?(attrs, to_string(field)))
  end
end

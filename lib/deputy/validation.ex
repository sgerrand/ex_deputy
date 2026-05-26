defmodule Deputy.Validation do
  @moduledoc """
  Shared input validation helpers used by resource modules before issuing
  API requests.
  """

  alias Deputy.Error.ValidationError

  @doc """
  Verify that every key in `required_fields` is present in `attrs` with a
  non-`nil`, non-empty-string value.

  Accepts either atom or string keys in `attrs` and matches against atom
  field names. Returns `:ok` if every required field has a usable value,
  or `{:error, %ValidationError{}}` for the first missing or blank field.

  Rejecting `nil` and `""` pre-flight catches calls that would otherwise
  hit the Deputy API and fail server-side with less useful errors.

  ## Examples

      iex> Deputy.Validation.required_fields(%{name: "foo", id: 1}, [:name, :id])
      :ok

      iex> Deputy.Validation.required_fields(%{"name" => "foo"}, [:name])
      :ok

      iex> {:error, %Deputy.Error.ValidationError{field: :id}} =
      ...>   Deputy.Validation.required_fields(%{name: "foo"}, [:name, :id])

      iex> {:error, %Deputy.Error.ValidationError{field: :name}} =
      ...>   Deputy.Validation.required_fields(%{name: nil}, [:name])

      iex> {:error, %Deputy.Error.ValidationError{field: :name}} =
      ...>   Deputy.Validation.required_fields(%{name: ""}, [:name])

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
    case fetch(attrs, field) do
      :error -> true
      {:ok, nil} -> true
      {:ok, ""} -> true
      {:ok, _} -> false
    end
  end

  defp fetch(attrs, field) do
    cond do
      Map.has_key?(attrs, field) -> {:ok, Map.get(attrs, field)}
      Map.has_key?(attrs, to_string(field)) -> {:ok, Map.get(attrs, to_string(field))}
      true -> :error
    end
  end
end

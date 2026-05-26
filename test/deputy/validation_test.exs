defmodule Deputy.ValidationTest do
  use ExUnit.Case, async: true
  doctest Deputy.Validation

  alias Deputy.Error.ValidationError
  alias Deputy.Validation

  describe "required_fields/2" do
    test "accepts atom keys" do
      assert Validation.required_fields(%{a: 1, b: 2}, [:a, :b]) == :ok
    end

    test "accepts string keys matching atom field names" do
      assert Validation.required_fields(%{"a" => 1, "b" => 2}, [:a, :b]) == :ok
    end

    test "returns ValidationError for the first missing field" do
      assert {:error, %ValidationError{field: :b, message: "missing required field: b"}} =
               Validation.required_fields(%{a: 1}, [:a, :b, :c])
    end

    test "rejects nil values" do
      assert {:error, %ValidationError{field: :a}} =
               Validation.required_fields(%{a: nil}, [:a])
    end

    test "rejects empty string values" do
      assert {:error, %ValidationError{field: :a}} =
               Validation.required_fields(%{a: ""}, [:a])
    end

    test "permits non-string falsy-adjacent values like 0 and false" do
      assert Validation.required_fields(%{a: 0, b: false}, [:a, :b]) == :ok
    end
  end
end

defmodule NumberF.RegistryTest do
  use ExUnit.Case
  doctest NumberF.Registry

  describe "modules/0" do
    test "returns list of module information" do
      modules = NumberF.Registry.modules()

      assert is_list(modules)
      assert length(modules) > 0

      # Check that each module has required fields
      Enum.each(modules, fn module ->
        assert Map.has_key?(module, :name)
        assert Map.has_key?(module, :description)
        assert Map.has_key?(module, :type)
      end)

      # Check for some key modules
      module_names = Enum.map(modules, & &1.name)
      assert "NumberF" in module_names
      assert "NumberF.Currency" in module_names
      assert "NumberF.Financial" in module_names
    end
  end

  describe "modules_by_type/1" do
    test "filters modules by type" do
      formatting_modules = NumberF.Registry.modules_by_type(:formatting)

      assert is_list(formatting_modules)
      assert length(formatting_modules) > 0

      # All modules should be of formatting type
      Enum.each(formatting_modules, fn module ->
        assert module.type == :formatting
      end)
    end

    test "returns empty list for unknown type" do
      unknown_modules = NumberF.Registry.modules_by_type(:unknown_type)
      assert unknown_modules == []
    end
  end

  describe "module_details/1" do
    test "returns module details for known module" do
      details = NumberF.Registry.module_details("NumberF.Currency")

      assert details.name == "NumberF.Currency"
      assert details.type == :formatting
      assert is_binary(details.description)
    end

    test "returns nil for unknown module" do
      details = NumberF.Registry.module_details("Unknown.Module")
      assert details == nil
    end
  end

  describe "function_categories/0" do
    test "returns list of function categories" do
      categories = NumberF.Registry.function_categories()

      assert is_list(categories)
      assert length(categories) > 0

      # Check that each category has required fields
      Enum.each(categories, fn category ->
        assert Map.has_key?(category, :name)
        assert Map.has_key?(category, :description)
        assert Map.has_key?(category, :examples)
        assert is_list(category.examples)
      end)

      # Check for some key categories
      category_names = Enum.map(categories, & &1.name)
      assert "Formatting" in category_names
      assert "Financial" in category_names
      assert "Statistical" in category_names
    end
  end

  describe "category_details/1" do
    test "returns category details for known category" do
      details = NumberF.Registry.category_details("Formatting")

      assert details.name == "Formatting"
      assert is_binary(details.description)
      assert is_list(details.examples)
    end

    test "returns nil for unknown category" do
      details = NumberF.Registry.category_details("Unknown Category")
      assert details == nil
    end
  end

  describe "to_markdown/0" do
    test "generates markdown documentation" do
      markdown = NumberF.Registry.to_markdown()

      assert is_binary(markdown)
      assert String.starts_with?(markdown, "# NumberF Library")
      assert String.contains?(markdown, "## Module Categories")
      assert String.contains?(markdown, "## Function Categories")
    end
  end
end

defmodule ConsoleMenuTest do
  use ExUnit.Case
  doctest ConsoleMenu

  test "push_menu" do
    menu_name = "Game Settings"
    menu_description = "Select the number of the settings item you wish to adjust"
    menu_state = %MetaMenu{}
    |> ConsoleMenu.push_menu(menu_name, menu_description)
    assert {:ok, ^menu_name} = MetaMenu.get_current_menu_title(menu_state)
    assert {:ok, ^menu_description} = MetaMenu.get_current_menu_description(menu_state)
  end

  test "set_title" do
    menu_name = "Game Settings"
    menu_state = %MetaMenu{}
    |> ConsoleMenu.push_menu()
    |> ConsoleMenu.set_title(menu_name)
    assert {:ok, ^menu_name} = MetaMenu.get_current_menu_title(menu_state)
  end

  test "set_description" do
    menu_description = "Select the number of the settings item you wish to adjust"
    menu_state = %MetaMenu{}
    |> ConsoleMenu.push_menu()
    |> ConsoleMenu.set_description(menu_description)
    assert {:ok, ^menu_description} = MetaMenu.get_current_menu_description(menu_state)
  end

  def on_select_mock(menu_state, _arguments) do
    ConsoleMenu.go_back(menu_state)
  end

  test "push_menu_item" do
    item_text = "Go Back"
    on_select = &__MODULE__.on_select_mock/2
    menu_state = %MetaMenu{}
    |> ConsoleMenu.push_menu("Menu 1", "_")
    |> ConsoleMenu.push_menu()
    |> ConsoleMenu.push_menu_item(item_text, on_select)
    MetaMenu.read_each_current_menu_item(menu_state, fn(index, text, custom_data) ->
      assert index === 1
      assert text === item_text
      assert custom_data.decorators === []
    end)
    ConsoleMenu.render_current_menu(menu_state)
    menu_state = ConsoleMenu.select_menu_item(menu_state, 1)
    |> ConsoleMenu.render_current_menu()
    assert {:ok, "Menu 1"} = MetaMenu.get_current_menu_title(menu_state)
  end

  test "push_forward_and_back_menu_items" do
    menu_state = %MetaMenu{}
    |> ConsoleMenu.push_menu("Menu 1", "_")
    |> ConsoleMenu.push_menu_item()
    |> ConsoleMenu.push_forward_and_back_menu_items()
    |> ConsoleMenu.push_menu("Menu 2", "_")
    |> ConsoleMenu.push_menu_item()
    |> ConsoleMenu.push_forward_and_back_menu_items()
    |> ConsoleMenu.render_current_menu()
    |> ConsoleMenu.select_menu_item(2)
    |> ConsoleMenu.render_current_menu()
    assert {:ok, "Menu 1"} = MetaMenu.get_current_menu_title(menu_state)
    menu_state = ConsoleMenu.select_menu_item(menu_state, 2)
    |> ConsoleMenu.render_current_menu()
    assert {:ok, "Menu 2"} = MetaMenu.get_current_menu_title(menu_state)
  end
end

defmodule ConsoleMenu do
  require MenuStateHandler
  alias ConsoleMenu.Formatter, as: Formatter
  alias ConsoleMenu.InputHandler, as: InputHandler

  @moduledoc """
  Module to format text only menus intended to run in a console, intended for text-based games.
  """

  def start_link, do:
    MenuStateHandler.start_link

  def push_new_menu(menu_title, request_text \\ "") do
    Formatter.format_title(menu_title)
    MenuStateHandler.push_menu([], %{title: menu_title, request_text: request_text})
  end

  def push_menu_item(item_name, callback) do
    item_index = MenuStateHandler.get_current_item_length()
    create_menu_item(item_index, item_name, callback)
    |> Formatter.format()
  end

  def push_forward_and_back_items do
    {
      MenuStateHandler.get_current(),
      MenuStateHandler.get_current_item_length()
    }
    |> push_forward_item()
    |> push_back_item()
  end

  def request_menu_selection do
    get_request_text()
    |> InputHandler.request_menu_selection()
    |> select_menu_item()
  end

  def select_menu_item(item_index) do
    MenuStateHandler.get_menu_item(item_index)
    |> case() do
      {:error, _error_type} -> Formatter.format_invalid_selection_error()
      %{on_select: on_select} -> on_select.()
    end
  end

  def go_forward do
    MenuStateHandler.go_forward()
    |> Formatter.format_menu()
    request_menu_selection()
  end

  def go_back do
    MenuStateHandler.go_back()
    |> Formatter.format_menu()
    request_menu_selection()
  end

  defp get_meta_data do 
    %{meta_data: meta_data} = MenuStateHandler.get_current()
    meta_data
  end

  defp get_request_text do
    get_meta_data()
    |> case() do
      %{request_text: request_text} -> request_text
      _meta_data -> ""
    end
  end

  defp push_forward_item({menu, item_index}) do
    case MenuStateHandler.can_go_forward?() do
      false -> {menu, item_index}
      true -> {MenuStateHandler.push_menu_item(create_forward_item(item_index)), item_index + 1}
    end
  end

  defp push_back_item({menu, item_index}) do
    case MenuStateHandler.can_go_backward?() do
      false -> {menu, item_index}
      true -> {MenuStateHandler.push_menu_item(create_back_item(item_index)), item_index + 1}
    end
  end

  defp create_forward_item(item_index) do
    create_menu_item(item_index, "Next menu", fn -> ConsoleMenu.go_forward() end)
    |> Formatter.format()
  end

  defp create_back_item(item_index) do
    create_menu_item(item_index, "Previous menu", fn -> ConsoleMenu.go_back() end)
    |> Formatter.format()
  end

  defp create_menu_item(item_index, item_text, on_select) do
    %{item_index: item_index, item_text: item_text, on_select: on_select}
  end

end

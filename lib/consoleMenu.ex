defmodule ConsoleMenu do
  require MetaMenu
  alias ConsoleMenu.Formatter, as: Formatter
  alias ConsoleMenu.InputHandler, as: InputHandler

  @moduledoc """
  Module to format text only menus intended to run in a console, intended for text-based games.
  """

  @forward_item_text "Show Next Menu"
  @back_item_text "Show Previous Menu"

  def push_menu(menu_state)  do 
    menu_state
    |> MetaMenu.push_menu()
    |> MetaMenu.update_current_menu_custom_data(&(Map.put(&1, :has_forward_item?, false)))
    |> MetaMenu.update_current_menu_custom_data(&(Map.put(&1, :has_back_item?, false)))
  end

  def push_menu(menu_state, menu_title) do
    push_menu(menu_state)
    |> MetaMenu.set_current_menu_title(menu_title)
  end

  def push_menu(menu_state, menu_title, description) do
    push_menu(menu_state, menu_title)
    |> MetaMenu.set_current_menu_description(description)
  end

  def pop_menu(menu_state), do:
    MetaMenu.pop_menu(menu_state)

  def render_current_menu(menu_state) do
    Formatter.format_current_menu(menu_state)
  end

  def set_title(menu_state, title), do:
    MetaMenu.set_current_menu_title menu_state, title

  def set_description(menu_state, description), do:
    MetaMenu.set_current_menu_description menu_state, description

  def push_menu_item(menu_state) do
    menu_state
    |> MetaMenu.push_menu_item()
    |> MetaMenu.update_last_menu_item_custom_data(&(Map.put(&1, :decorators, [])))
  end

  def push_menu_item(menu_state, item_text, on_select, on_select_arguments \\ []) do
    menu_state
    |> push_menu_item()
    |> MetaMenu.set_last_menu_item_index()
    |> MetaMenu.set_last_menu_item_text(item_text)
    |> MetaMenu.set_last_menu_item_select_callback(on_select)
    |> MetaMenu.set_last_menu_item_select_arguments(on_select_arguments)
  end

  def go_back(menu_state) do
    menu_state
    |> MetaMenu.go_back()
    |> ConsoleMenu.push_forward_item()
  end

  def on_select_back_item(menu_state, _arguments), do:
    go_back(menu_state)

  def go_forward(menu_state), do:
    MetaMenu.go_forward menu_state

  def on_select_forward_item(menu_state, _arguments), do:
    go_forward(menu_state)

  def push_forward_and_back_menu_items(menu_state) do
    MetaMenu.update_last_menu_item_custom_data(menu_state, fn
      %{decorators: []} = custom_data -> %{custom_data | decorators: [:bottom_line]}
      custom_data -> %{custom_data | decorators: [:bottom_line | tl(custom_data.decorators)]}
    end)
    |> push_forward_item()
    |> push_back_item()
  end

  def push_forward_item(menu_state) do
    {:ok, custom_data} = MetaMenu.get_current_menu_custom_data(menu_state)
    with true <- MetaMenu.can_go_forward?(menu_state),
      false <- custom_data.has_forward_item?
    do
      menu_state
      |> MetaMenu.update_current_menu_custom_data(&(Map.put(&1, :has_forward_item?, true)))
      |> push_menu_item(@forward_item_text, &__MODULE__.on_select_forward_item/2)
    else
      _ -> menu_state
    end
  end

  def push_back_item(menu_state) do
    {:ok, custom_data} = MetaMenu.get_current_menu_custom_data(menu_state)
    with true <- MetaMenu.can_go_backward?(menu_state),
      false <- custom_data.has_back_item?
    do
      menu_state
      |> MetaMenu.update_current_menu_custom_data(&(Map.put(&1, :has_back_item?, true)))
      |> push_menu_item(@back_item_text, &__MODULE__.on_select_back_item/2)
    else
      _ -> menu_state
    end
  end

  def request_menu_selection(menu_state) do
    with :error <- InputHandler.request_menu_selection() do
      Formatter.format_error_message()
    else
      input -> select_menu_item(menu_state, input)
    end
  end

  def select_menu_item(menu_state, item_index) do
    with {:error, _} <- MetaMenu.select_menu_item(menu_state, item_index) do
      Formatter.format_error_message()
      menu_state
    end
  end
end

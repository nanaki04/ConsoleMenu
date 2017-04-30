defmodule ConsoleMenu.Formatter do

  def format_title(title) do
    IO.puts("------------------------------")
    IO.puts(title)
    IO.puts("______________________________")
    IO.puts("type the number of the item you wish to select")
    IO.puts("")
    title
  end

  def format(%{item_index: item_index, item_text: item_text} = menu_item) do
    IO.puts(to_string(item_index) <> ". " <> item_text)
    menu_item
  end

  def format_menu(%{items: items, meta_data: %{title: title}} = menu) do
    format_title title
    Enum.each(items, fn(item) -> format(item) end)
    menu
  end

  def format_invalid_selection_error do
    IO.puts("The selection you have entered is invalid, please type the number of the menu item you wish to select.")
  end

end

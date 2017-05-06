defmodule ConsoleMenu.Formatter do

  def format_current_menu(menu_state) do
    menu_state
    |> format_title()
    |> format_description()
    |> MetaMenu.read_each_current_menu_item(fn(index, text, custom_data) ->
      Enum.each(custom_data.decorators, &(apply(__MODULE__, &1, [:top_decorator])))
      IO.puts(to_string(index) <> ". " <> text)
      Enum.each(custom_data.decorators, &(apply(__MODULE__, &1, [:bottom_decorator])))
    end)
  end

  def format_error_message() do
    IO.puts("The selection you have entered is invalid, please type the number of the menu item you wish to select.")
  end

  defp format_title(menu_state) do
    {:ok, title} = MetaMenu.get_current_menu_title(menu_state)
    IO.puts("------------------------------")
    IO.puts(title)
    IO.puts("______________________________")
    menu_state
  end

  defp format_description(menu_state) do
    {:ok, description} = MetaMenu.get_current_menu_description(menu_state)
    IO.puts(description)
    IO.puts("")
    menu_state
  end

  def bottom_line(:top_decorator), do: nil
  def bottom_line(:bottom_decorator) do
    IO.puts("______________________________")
  end
end

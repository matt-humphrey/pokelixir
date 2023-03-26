defmodule Pokemon do
  @moduledoc """
  An exercise from DockYard Academy to practice extracting data from APIs.
  """

  @enforce_keys [:id, :name, :hp, :attack, :defense, :special_attack, :special_defense, :speed, :height, :weight, :types]
  defstruct @enforce_keys

  @doc """
  Return the stats of a given Pokemon as a struct.
  """
  @spec get(String.t()) :: struct()
  def get(pokemon) do
    {:ok, response} = HTTPoison.get("https://pokeapi.co/api/v2/pokemon/" <> pokemon)
    parsed = Poison.decode!(response.body)

    stats =
      Enum.reduce(parsed["stats"], %{}, fn stat, acc ->
        %{"base_stat" => base_stat, "stat" => %{"name" => name}} = stat
        Map.put(acc, name, base_stat)
      end)

    types =
      Enum.map(parsed["types"], fn type ->
        %{"type" => %{"name" => name}} = type
        name
      end)

    %Pokemon{
      id: parsed["id"],
      name: parsed["name"],
      hp: stats["hp"],
      attack: stats["attack"],
      defense: stats["defense"],
      special_attack: stats["special-attack"],
      special_defense: stats["special-defense"],
      speed: stats["speed"],
      height: parsed["height"],
      weight: parsed["weight"],
      types: types
    }
  end

  @doc """
  Return the stats of ALL Pokemon as structs.
  """
  @spec all() :: [struct()]
  def all() do
    do_all([], "https://pokeapi.co/api/v2/pokemon")
  end

  defp do_all(pokemon_list, nil), do: pokemon_list
  defp do_all(pokemon_list, url) do
    {:ok, response} = HTTPoison.get(url)
    IO.puts("Response received.")
    parsed = Poison.decode!(response.body)
    new_pokemon_list =
      parsed["results"]
      |> Enum.map(fn pokemon -> pokemon["name"] end)
      |> Enum.map(&get/1)

    do_all([new_pokemon_list | pokemon_list], parsed["next"])
  end

end

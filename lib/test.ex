defmodule AshOban.Test do
  @moduledoc "Helpers for testing ash_oban triggers"

  def schedule_and_run_triggers(resource) do
    triggers =
      AshOban.Info.oban_triggers(resource)

    Enum.each(triggers, fn trigger ->
      AshOban.schedule(resource, trigger)
    end)

    triggers
    |> Enum.map(& &1.queue)
    |> Enum.uniq()
    |> Enum.reduce(%{}, fn queue, acc ->
      [queue: queue]
      |> Oban.drain_queue()
      |> Map.merge(acc, fn _key, left, right ->
        left + right
      end)
    end)
  end
end

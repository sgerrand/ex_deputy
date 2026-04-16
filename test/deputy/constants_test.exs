defmodule Deputy.ConstantsTest do
  use ExUnit.Case, async: true
  doctest Deputy.Constants
  doctest Deputy.Constants.Gender
  doctest Deputy.Constants.LeaveStatus
  doctest Deputy.Constants.Roster
  doctest Deputy.Constants.Webhook
end

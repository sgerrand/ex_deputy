defmodule Deputy.ConstantsTest do
  use ExUnit.Case, async: true

  alias Deputy.Constants.{Roster, Webhook}

  doctest Deputy.Constants
  doctest Deputy.Constants.Gender
  doctest Deputy.Constants.LeaveStatus
  doctest Deputy.Constants.Roster
  doctest Deputy.Constants.Webhook

  describe "Roster" do
    test "all_locations/0 returns 1" do
      assert Roster.all_locations() == 1
    end

    test "single_location/0 returns 0" do
      assert Roster.single_location() == 0
    end
  end

  describe "Webhook" do
    test "topic_timesheet_insert/0 returns correct string" do
      assert Webhook.topic_timesheet_insert() == "Timesheet.Insert"
    end

    test "topic_timesheet_update/0 returns correct string" do
      assert Webhook.topic_timesheet_update() == "Timesheet.Update"
    end

    test "topic_employee_insert/0 returns correct string" do
      assert Webhook.topic_employee_insert() == "Employee.Insert"
    end

    test "topic_employee_update/0 returns correct string" do
      assert Webhook.topic_employee_update() == "Employee.Update"
    end

    test "topic_roster_insert/0 returns correct string" do
      assert Webhook.topic_roster_insert() == "Roster.Insert"
    end

    test "topic_roster_update/0 returns correct string" do
      assert Webhook.topic_roster_update() == "Roster.Update"
    end
  end
end

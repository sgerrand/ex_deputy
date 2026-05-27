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

  describe "Gender guards" do
    import Deputy.Constants.Gender

    test "is_male/1, is_female/1, is_unspecified/1 match their codes" do
      assert is_male(1)
      assert is_female(2)
      assert is_unspecified(3)
      refute is_male(2)
    end

    test "guards work in case clauses" do
      label = classify_gender(female())

      assert label == :female
    end

    defp classify_gender(g) when is_male(g), do: :male
    defp classify_gender(g) when is_female(g), do: :female
    defp classify_gender(g) when is_unspecified(g), do: :unspecified
  end

  describe "LeaveStatus guards" do
    import Deputy.Constants.LeaveStatus

    test "matches each status code" do
      assert is_pending(0)
      assert is_approved(1)
      assert is_declined(2)
      assert is_cancelled(3)
      refute is_approved(0)
    end
  end

  describe "Roster guards" do
    import Deputy.Constants.Roster

    test "publish_mode and locations guards" do
      assert is_publish_mode_notify(1)
      assert is_publish_mode_silent(2)
      assert is_all_locations(1)
      assert is_single_location(0)
    end
  end

  describe "Webhook guards" do
    import Deputy.Constants.Webhook

    test "string-equality guards match each topic" do
      assert is_type_url("URL")
      assert is_topic_timesheet_insert("Timesheet.Insert")
      assert is_topic_timesheet_update("Timesheet.Update")
      assert is_topic_employee_insert("Employee.Insert")
      assert is_topic_employee_update("Employee.Update")
      assert is_topic_roster_insert("Roster.Insert")
      assert is_topic_roster_update("Roster.Update")
      refute is_topic_timesheet_insert("Timesheet.Update")
    end
  end
end

defmodule Deputy.Constants do
  @moduledoc """
  Named constants for Deputy API magic values.

  The Deputy API uses integer codes for many fields. This module provides
  named constants to avoid magic numbers in application code.

  ## Usage

      iex> Deputy.Constants.Gender.male()
      1

      iex> Deputy.Constants.Roster.publish_mode_notify()
      1

  """

  defmodule Gender do
    @moduledoc """
    Integer codes for the `intGender` field used in employee creation.

    ## Examples

        iex> Deputy.Constants.Gender.male()
        1

        iex> Deputy.Constants.Gender.female()
        2

        iex> Deputy.Constants.Gender.unspecified()
        3

    """

    @doc "Male (intGender: 1)"
    def male, do: 1

    @doc "Female (intGender: 2)"
    def female, do: 2

    @doc "Not specified (intGender: 3)"
    def unspecified, do: 3
  end

  defmodule LeaveStatus do
    @moduledoc """
    Integer codes for the `Status` field used in leave creation and approval.

    ## Examples

        iex> Deputy.Constants.LeaveStatus.pending()
        0

        iex> Deputy.Constants.LeaveStatus.approved()
        1

        iex> Deputy.Constants.LeaveStatus.declined()
        2

        iex> Deputy.Constants.LeaveStatus.cancelled()
        3

    """

    @doc "Pending approval (Status: 0)"
    def pending, do: 0

    @doc "Approved (Status: 1)"
    def approved, do: 1

    @doc "Declined (Status: 2)"
    def declined, do: 2

    @doc "Cancelled (Status: 3)"
    def cancelled, do: 3
  end

  defmodule Roster do
    @moduledoc """
    Integer codes used in roster publishing and management.

    ## Examples

        iex> Deputy.Constants.Roster.publish_mode_notify()
        1

        iex> Deputy.Constants.Roster.publish_mode_silent()
        2

    """

    @doc "Publish and notify employees (intMode: 1)"
    def publish_mode_notify, do: 1

    @doc "Publish without notification (intMode: 2)"
    def publish_mode_silent, do: 2

    @doc "All locations mode enabled (blnAllLocationsMode: 1)"
    def all_locations, do: 1

    @doc "All locations mode disabled (blnAllLocationsMode: 0)"
    def single_location, do: 0
  end

  defmodule Webhook do
    @moduledoc """
    Topic strings and type codes for webhook registration.

    See `Deputy.Utility.add_webhook/2`.

    ## Examples

        iex> Deputy.Constants.Webhook.type_url()
        "URL"

    """

    @doc ~S'Webhook type for HTTP URL callbacks (Type: "URL")'
    def type_url, do: "URL"

    @doc ~S'Timesheet insert event (Topic: "Timesheet.Insert")'
    def topic_timesheet_insert, do: "Timesheet.Insert"

    @doc ~S'Timesheet update event (Topic: "Timesheet.Update")'
    def topic_timesheet_update, do: "Timesheet.Update"

    @doc ~S'Employee insert event (Topic: "Employee.Insert")'
    def topic_employee_insert, do: "Employee.Insert"

    @doc ~S'Employee update event (Topic: "Employee.Update")'
    def topic_employee_update, do: "Employee.Update"

    @doc ~S'Roster insert event (Topic: "Roster.Insert")'
    def topic_roster_insert, do: "Roster.Insert"

    @doc ~S'Roster update event (Topic: "Roster.Update")'
    def topic_roster_update, do: "Roster.Update"
  end
end

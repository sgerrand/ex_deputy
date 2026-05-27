defmodule Deputy.Constants do
  @moduledoc """
  Named constants for Deputy API magic values.

  The Deputy API uses integer codes for many fields. This module provides
  named constants to avoid magic numbers in application code.

  Each child module exposes both:

  * Plain functions (e.g. `Gender.male/0`) that return the raw value.
    Use these to build request payloads.
  * `defguard`-based predicates (e.g. `Gender.is_male/1`) usable in
    guards and `case` clauses for response handling.

  ## Usage

      iex> Deputy.Constants.Gender.male()
      1

      iex> Deputy.Constants.Roster.publish_mode_notify()
      1

      iex> import Deputy.Constants.LeaveStatus
      iex> case 1 do
      ...>   s when is_approved(s) -> :approved
      ...>   s when is_pending(s) -> :pending
      ...>   _ -> :other
      ...> end
      :approved

  """

  defmodule Gender do
    @moduledoc """
    Integer codes for the `intGender` field used in employee creation.

    Use the functions below to embed values in request payloads and the
    `is_*/1` guards to pattern-match on responses.

    ## Examples

        iex> Deputy.Constants.Gender.male()
        1

        iex> Deputy.Constants.Gender.female()
        2

        iex> Deputy.Constants.Gender.unspecified()
        3

        iex> import Deputy.Constants.Gender
        iex> is_male(1)
        true

    """

    @male 1
    @female 2
    @unspecified 3

    @doc "Guard: matches the `male` gender code (`1`)."
    defguard is_male(value) when value == @male

    @doc "Guard: matches the `female` gender code (`2`)."
    defguard is_female(value) when value == @female

    @doc "Guard: matches the `unspecified` gender code (`3`)."
    defguard is_unspecified(value) when value == @unspecified

    @doc "Male (intGender: 1)"
    def male, do: @male

    @doc "Female (intGender: 2)"
    def female, do: @female

    @doc "Not specified (intGender: 3)"
    def unspecified, do: @unspecified
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

        iex> import Deputy.Constants.LeaveStatus
        iex> is_approved(1)
        true

    """

    @pending 0
    @approved 1
    @declined 2
    @cancelled 3

    @doc "Guard: matches the `pending` leave status (`0`)."
    defguard is_pending(value) when value == @pending

    @doc "Guard: matches the `approved` leave status (`1`)."
    defguard is_approved(value) when value == @approved

    @doc "Guard: matches the `declined` leave status (`2`)."
    defguard is_declined(value) when value == @declined

    @doc "Guard: matches the `cancelled` leave status (`3`)."
    defguard is_cancelled(value) when value == @cancelled

    @doc "Pending approval (Status: 0)"
    def pending, do: @pending

    @doc "Approved (Status: 1)"
    def approved, do: @approved

    @doc "Declined (Status: 2)"
    def declined, do: @declined

    @doc "Cancelled (Status: 3)"
    def cancelled, do: @cancelled
  end

  defmodule Roster do
    @moduledoc """
    Integer codes used in roster publishing and management.

    ## Examples

        iex> Deputy.Constants.Roster.publish_mode_notify()
        1

        iex> Deputy.Constants.Roster.publish_mode_silent()
        2

        iex> import Deputy.Constants.Roster
        iex> is_publish_mode_notify(1)
        true

    """

    @publish_mode_notify 1
    @publish_mode_silent 2
    @all_locations 1
    @single_location 0

    @doc "Guard: matches the publish-and-notify mode (`1`)."
    defguard is_publish_mode_notify(value) when value == @publish_mode_notify

    @doc "Guard: matches the publish-without-notification mode (`2`)."
    defguard is_publish_mode_silent(value) when value == @publish_mode_silent

    @doc "Guard: matches the all-locations flag (`1`)."
    defguard is_all_locations(value) when value == @all_locations

    @doc "Guard: matches the single-location flag (`0`)."
    defguard is_single_location(value) when value == @single_location

    @doc "Publish and notify employees (intMode: 1)"
    def publish_mode_notify, do: @publish_mode_notify

    @doc "Publish without notification (intMode: 2)"
    def publish_mode_silent, do: @publish_mode_silent

    @doc "All locations mode enabled (blnAllLocationsMode: 1)"
    def all_locations, do: @all_locations

    @doc "All locations mode disabled (blnAllLocationsMode: 0)"
    def single_location, do: @single_location
  end

  defmodule Webhook do
    @moduledoc """
    Topic strings and type codes for webhook registration.

    See `Deputy.Utility.add_webhook/2`.

    ## Examples

        iex> Deputy.Constants.Webhook.type_url()
        "URL"

        iex> import Deputy.Constants.Webhook
        iex> is_topic_timesheet_insert("Timesheet.Insert")
        true

    """

    @type_url "URL"
    @topic_timesheet_insert "Timesheet.Insert"
    @topic_timesheet_update "Timesheet.Update"
    @topic_employee_insert "Employee.Insert"
    @topic_employee_update "Employee.Update"
    @topic_roster_insert "Roster.Insert"
    @topic_roster_update "Roster.Update"

    @doc ~S'Guard: matches the URL webhook type (`"URL"`).'
    defguard is_type_url(value) when value == @type_url

    @doc ~S'Guard: matches the `"Timesheet.Insert"` topic string.'
    defguard is_topic_timesheet_insert(value) when value == @topic_timesheet_insert

    @doc ~S'Guard: matches the `"Timesheet.Update"` topic string.'
    defguard is_topic_timesheet_update(value) when value == @topic_timesheet_update

    @doc ~S'Guard: matches the `"Employee.Insert"` topic string.'
    defguard is_topic_employee_insert(value) when value == @topic_employee_insert

    @doc ~S'Guard: matches the `"Employee.Update"` topic string.'
    defguard is_topic_employee_update(value) when value == @topic_employee_update

    @doc ~S'Guard: matches the `"Roster.Insert"` topic string.'
    defguard is_topic_roster_insert(value) when value == @topic_roster_insert

    @doc ~S'Guard: matches the `"Roster.Update"` topic string.'
    defguard is_topic_roster_update(value) when value == @topic_roster_update

    @doc ~S'Webhook type for HTTP URL callbacks (Type: "URL")'
    def type_url, do: @type_url

    @doc ~S'Timesheet insert event (Topic: "Timesheet.Insert")'
    def topic_timesheet_insert, do: @topic_timesheet_insert

    @doc ~S'Timesheet update event (Topic: "Timesheet.Update")'
    def topic_timesheet_update, do: @topic_timesheet_update

    @doc ~S'Employee insert event (Topic: "Employee.Insert")'
    def topic_employee_insert, do: @topic_employee_insert

    @doc ~S'Employee update event (Topic: "Employee.Update")'
    def topic_employee_update, do: @topic_employee_update

    @doc ~S'Roster insert event (Topic: "Roster.Insert")'
    def topic_roster_insert, do: @topic_roster_insert

    @doc ~S'Roster update event (Topic: "Roster.Update")'
    def topic_roster_update, do: @topic_roster_update
  end
end

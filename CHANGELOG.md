# Changelog

## v1.0.0-rc.0

### Breaking changes

- Support multiple Commanded apps ([#298](https://github.com/commanded/commanded/pull/298)).

### Upgrading

[Follow the upgrade guide](guides/upgrades/0.19-1.0.md) to define and use your own Commanded application.

## v0.19.1

### Enhancements

- Reset event handler mix task `mix commanded.reset MyApp.Handler` ([#293](https://github.com/commanded/commanded/pull/293)).

### Bug fixes

- Fix regression in `Commanded.Middleware.Logger.delta` ([#295](https://github.com/commanded/commanded/pull/295)).

## v0.19.0

### Enhancements

- Update typespec for `data` and `metadata` fields in `Commanded.EventStore.EventData` struct ([#246](https://github.com/commanded/commanded/pull/246)).
- Add `include_execution_result` and `aggregate_version` to typespec for router command dispatch ([#262](https://github.com/commanded/commanded/pull/262)).
- Add `.formatter.exs` to Hex package ([#247](https://github.com/commanded/commanded/pull/247)).
- Event upcasting ([#263](https://github.com/commanded/commanded/pull/263)).
- Support `:ok` tagged tuple events from aggregate ([#268](https://github.com/commanded/commanded/pull/268)).
- Modify `Commanded.Registration.start_child` to pass a child_spec ([#273](https://github.com/commanded/commanded/pull/273)).
- Add `supervisor_child_spec/2` to `Commanded.Registration` behaviour ([#277](https://github.com/commanded/commanded/pull/277)) used by [Commanded Horde Registry](https://github.com/uberbrodt/commanded_horde_registry).
- Ensure Commanded can be compiled when optional Jason dependency is not present ([#286](https://github.com/commanded/commanded/pull/286)).
- Fix Aggregate initialization races ([#287](https://github.com/commanded/commanded/pull/287)).
- Support `{:system, varname}` format in Phoenix PubSub config ([#291](https://github.com/commanded/commanded/pull/291)).

### Breaking changes

- Use `DateTime` instead of `NaiveDateTime` for all datetimes ([#254](https://github.com/commanded/commanded/pull/254)).

    This affects the `created_at` field defined in the `Commanded.EventStore.RecordedEvent`. You will need to migrate from `NaiveDateTime` to `DateTime` if you use this field in your code (such as in an event handler's metadata).

---

## v0.18.1

### Enhancements

- Process manager idle process timeout ([#290](https://github.com/commanded/commanded/pull/290)).
- Register event handler and process manager subscriptions on process start ([#272](https://github.com/commanded/commanded/pull/272)).

## v0.18.0

### Enhancements

- Rename `uuid` dependency to `elixir_uuid` ([#178](https://github.com/commanded/commanded/pull/178)).
- Allow aggregate identity to be of any type that implements the `String.Chars` protocol ([#166](https://github.com/commanded/commanded/pull/166)).
- Process manager and event handler error & exception handling ([#192](https://github.com/commanded/commanded/pull/192)).
- Process manager event handling timeout ([#193](https://github.com/commanded/commanded/pull/193)).
- Allow event handlers to subscribe to individual streams ([#203](https://github.com/commanded/commanded/pull/203)).
- Add new values for `expected_version` for event store append events behaviour ([#127](https://github.com/commanded/commanded/pull/127)).
- Export `Commanded.Commands.Router` macros in `.formatter.exs` file ([#204](https://github.com/commanded/commanded/pull/204)).
- Generate specs and docs for Router dispatch functions only once ([#206](https://github.com/commanded/commanded/pull/206)).
- Allow two-arity predicate function in `wait_for_event` receiving both event data and recorded event struct ([#213](https://github.com/commanded/commanded/pull/213)).
- Allow `:infinity` timeout on command dispatch ([#227](https://github.com/commanded/commanded/pull/227))
- Strict process manager routing ([#243](https://github.com/commanded/commanded/pull/243)).
- Allow `Commanded.Aggregate.Multi` to be nested ([#244](https://github.com/commanded/commanded/pull/244)).
- Add `child_spec/0` function to `Commanded.EventStore` behaviour.
- Add `delete_subscription/2` to `Commanded.EventStore` behaviour ([#245](https://github.com/commanded/commanded/pull/245)).
- Add `refute_receive_event/2` to `Commanded.Assertions.EventAssertions` test helpers.

### Bug fixes

- Fix typo in `include_execution_result` global router option ([#216](https://github.com/commanded/commanded/pull/216)).
- Handle the `{:ok, _}` tuple dispatch result in process manager command dispatch ([#236](https://github.com/commanded/commanded/pull/236)).
- Allow string keys for `Commanded.Middleware.Pipeline.assign_metadata/3`, atoms are being deprecated ([#228](https://github.com/commanded/commanded/pull/228))
- Fix `Commanded.PubSub.subscribe` typespec ([#222](https://github.com/commanded/commanded/pull/222)).

### Breaking changes

- Migrate to [Jason](https://hex.pm/packages/jason) for JSON serialization ([#234](https://github.com/commanded/commanded/pull/234)).

  You will need to add Jason as a dependency in `mix.exs`:

  ```elixir
  defp deps do
    [{:jason, "~> 1.1"}]
  end
  ```

  Jason has _no support_ for encoding arbitrary structs - explicit implementation of the `Jason.Encoder` protocol is always required. You *must* update all your domain event modules, aggregate state (when using state snapshotting), and process manager state to include `@derive Jason.Encoder` as shown below:

  ```elixir
  defmodule AnEvent do
    @derive Jason.Encoder
    defstruct [:field]
  end
  ```

- Extend aggregate lifespan behaviour to include `after_error/1` and `after_command/1` callbacks ([#210](https://github.com/commanded/commanded/pull/210)).

  Previously you only had to define an `after_event/1` callback function to implement the `Commanded.Aggregates.AggregateLifespan` behaviour:

  ```elixir
  defmodule BankAccountLifespan do
    @behaviour Commanded.Aggregates.AggregateLifespan

    def after_event(%BankAccountClosed{}), do: :stop
    def after_event(_event), do: :infinity
  end
  ```

  Now you must also define `after_command/1` and `after_error/1` callback functions:

  ```elixir
  defmodule BankAccountLifespan do
    @behaviour Commanded.Aggregates.AggregateLifespan

    def after_event(%BankAccountClosed{}), do: :stop
    def after_event(_event), do: :infinity

    def after_command(%CloseAccount{}), do: :stop
    def after_command(_command), do: :infinity

    def after_error(:invalid_initial_balance), do: :stop
    def after_error(_error), do: :stop
  end
  ```

### Upgrading

Please ensure you upgrade the following event store dependencies.

Using the Elixir [EventStore](https://github.com/commanded/eventstore):

- `eventstore` to [v0.16.0](https://hex.pm/packages/eventstore)
- `commanded_eventstore_adapter` to [v0.5.0](https://hex.pm/packages/commanded_eventstore_adapter)

Using Greg Young's [Event Store](https://eventstore.org/):

- `commanded_extreme_adapter` to [v0.6.0](https://hex.pm/packages/commanded_extreme_adapter)

Commanded Ecto projections:

- `commanded_ecto_projections` to [v0.8.0](https://hex.pm/packages/commanded_ecto_projections)

Commanded scheduler:

- `commanded_scheduler` to [v0.2.0](https://hex.pm/packages/commanded_scheduler)

---

## v0.17.5

### Enhancements

- Process manager idle process timeout ([#290](https://github.com/commanded/commanded/pull/290)).

## v0.17.4

### Bug fixes

- Register event handler and process manager subscriptions on process start ([#272](https://github.com/commanded/commanded/pull/272)).

## v0.17.3

### Bug fixes

- Fix snapshot recording ([#196](https://github.com/commanded/commanded/pull/196)).
- Fixed warning about deprecated time unit in elixir 1.8 ([#239](https://github.com/commanded/commanded/pull/239)).

## v0.17.2

### Enhancements

- Remove default `error/4` callback function from process manager to silence deprecation warning.

## v0.17.1

### Enhancements

- Support `Phoenix.PubSub` v1.1.0.

### Bug fixes

- Set default aggregate lifespan timeout to `:infinity` ([#200](https://github.com/commanded/commanded/pull/200)).

## v0.17.0

### Enhancements

- Ability to globally override `include_execution_result` and `include_aggregate_version` in environment config ([#168](https://github.com/commanded/commanded/pull/168)).
- Handle custom type serialization in snapshot source type ([#165](https://github.com/commanded/commanded/pull/165)).
- Fix compiler warnings in generated code (routers, event handlers, and process managers).
- Add `InMemory.reset!/0` for testing purposes ([#175](https://github.com/commanded/commanded/pull/175)).

### Bug fixes

- Ensure process managers can be configured with `:strong` consistency.
- Fix error when subscription process already tracked ([#180](https://github.com/commanded/commanded/pull/180)).

---

## v0.16.0

- Support composite command routers ([#111](https://github.com/commanded/commanded/pull/111)).
- Aggregate state snapshots ([#121](https://github.com/commanded/commanded/pull/121)).
- New `error/3` callback for process manager and deprecated `error/4` ([#124](https://github.com/commanded/commanded/pull/124))
- Router support for identity prefix function.
- Retry command execution on concurrency error ([#132](https://github.com/commanded/commanded/pull/132)).
- Event handler `error/3` callback ([#133](https://github.com/commanded/commanded/pull/133)).
- Support distributed dispatch consistency ([#135](https://github.com/commanded/commanded/pull/135)).
- Defer event handler and process router init until after subscribed ([#138](https://github.com/commanded/commanded/pull/138)).
- Replace aggregate lifespan `after_command/1` callback with `after_event/1` ([#139](https://github.com/commanded/commanded/issues/139)).
- Support process manager routing to multiple instances ([#141](https://github.com/commanded/commanded/pull/141)).
- Allow a default consistency to be set via the application env ([#150](https://github.com/commanded/commanded/pull/150)).
- Command dispatch consistency using explicit handler names ([#161](https://github.com/commanded/commanded/pull/161)).

### Breaking changes

- The `Commanded.Aggregates.AggregateLifespan` behaviour has been changed from `after_command/1` to `after_event/1`. You will need to update your own lifespan modules to use events instead of commands to shutdown an aggregate process after an inactivity timeout.

### Upgrading

Please ensure you upgrade the following event store dependencies.

Using the Elixir [EventStore](https://github.com/commanded/eventstore):

- `eventstore` to [v0.14.0](https://hex.pm/packages/eventstore)
- `commanded_eventstore_adapter` to [v0.4.0](https://hex.pm/packages/commanded_eventstore_adapter)

Using Greg Young's [Event Store](https://eventstore.org/):

- `commanded_extreme_adapter` to [v0.5.0](https://hex.pm/packages/commanded_extreme_adapter)

---

## v0.15.1

### Bug fixes

- Event handler `child_spec/1` must include config options defined by use macro.

## v0.15.0

### Enhancements

- Process manager command dispatch error handling ([#93](https://github.com/commanded/commanded/issues/93)).
- Event handlers may define an `init/0` callback function to start any related processes. It must return `:ok`, otherwise the handler process will be stopped.
- Add `include_execution_result` option to command dispatch ([#96](https://github.com/commanded/commanded/pull/96)).
- Add `Commanded.Aggregate.Multi` ([#98](https://github.com/commanded/commanded/pull/98)) as a way to return multiple events from a command dispatch that require aggregate state to be updated after each event.
- Correlation and causation ids ([#105](https://github.com/commanded/commanded/pull/105)).
- Initial support for running on a cluster of nodes ([#80](https://github.com/commanded/commanded/pull/80)).

### Bug fixes

- Adding a prefix to the aggregate in the router breaks the strong consistency of command dispatch ([#101](https://github.com/commanded/commanded/issues/101)).

### Upgrading

Please ensure you upgrade the following event store dependencies.

Using the Elixir [EventStore](https://github.com/commanded/eventstore):

- `eventstore` to [v0.13.0](https://hex.pm/packages/eventstore)
- `commanded_eventstore_adapter` to [v0.3.0](https://hex.pm/packages/commanded_eventstore_adapter)

Using Greg's [Event Store](https://eventstore.org/):

- `commanded_extreme_adapter` to [v0.4.0](https://hex.pm/packages/commanded_extreme_adapter)

---

## v0.14.0

### Enhancements

- Dispatch command with `:eventual` or `:strong` consistency guarantee ([#82](https://github.com/commanded/commanded/issues/82)).
- Additional stream prefix per aggregate ([#77](https://github.com/commanded/commanded/issues/77)).
- Include custom metadata during command dispatch ([#61](https://github.com/commanded/commanded/issues/61)).
- Validate command dispatch registration in router ([59](https://github.com/commanded/commanded/issues/59)).

### Upgrading

Please ensure you upgrade the following event store dependencies.

Using the Elixir [EventStore](https://github.com/commanded/eventstore):

- `eventstore` to [v0.11.0](https://hex.pm/packages/eventstore)
- `commanded_eventstore_adapter` to [v0.2.0](https://hex.pm/packages/commanded_eventstore_adapter)

Using Greg's [Event Store](https://eventstore.org/):

- `commanded_extreme_adapter` to [v0.3.0](https://hex.pm/packages/commanded_extreme_adapter)

---

## v0.13.0

### Enhancements

- Command dispatch optionally returns aggregate version, using `include_aggregate_version: true` during dispatch.

---

## v0.12.0

### Enhancements

- `Commanded.Event.Handler` and `Commanded.ProcessManagers.ProcessManager` macros to simplify defining, and starting, event handlers and process managers. Note the previous approach to defining and starting may still be used, so this is *not* a breaking change.

---

## v0.11.0

### Enhancements

- Shutdown idle aggregate processes ([#43](https://github.com/commanded/commanded/issues/43)).

---

## v0.10.0

### Enhancements

- Extract event store integration to a behaviour (`Commanded.EventStore`). This defines the contract to be implemented by an event store adapter. It allows additional event store databases to be used with Commanded.

  By default, a `GenServer` in-memory event store adapter is used. This should **only be used for testing** as there is no persistence.

  The existing PostgreSQL-based [eventstore](https://github.com/commanded/eventstore) integration has been extracted as a separate package ([commanded_eventstore_adapter](https://github.com/commanded/commanded-eventstore-adapter)). There is also a new adapter for Greg Young's Event Store using the Extreme library ([commanded_extreme_adapter](https://github.com/commanded/commanded-extreme-adapter)).

  You must install the required event store adapter package and update your environment configuration to specify the `:event_store_adapter` module. See the [README](https://github.com/commanded/commanded/blob/master/README.md) for details.

---

## v0.9.0

### Enhancements

- Stream events from event store when rebuilding aggregate state.

---

## v0.8.5

### Enhancements

- Upgrade to Elixir 1.4 and remove compiler warnings.

## v0.8.4

### Enhancements

- Event handler and process manager subscriptions should be created from a given stream position ([#14](https://github.com/commanded/commanded/issues/14)).
- Stop process manager instance after reaching its final state ([#24](https://github.com/commanded/commanded/issues/24)).

## v0.8.3

### Enhancements

- Middleware `after_failure` callback is executed even when a middleware halts execution.

## v0.8.2

### Bug fixes

- JsonSerializer should ensure event type atom exists when deserializing ([#28](https://github.com/commanded/commanded/issues/28)).

## v0.8.1

### Enhancements

- Command handlers should be optional by default ([#30](https://github.com/commanded/commanded/issues/30)).

## v0.8.0

### Enhancements

- Simplify aggregates and process managers ([#31](https://github.com/commanded/commanded/issues/31)).

---

## v0.7.1

### Bug fixes

- Restarting aggregate process should load all events from its stream in batches. The Event Store read stream default limit is 1,000 events.

## v0.7.0

### Enhancements

- Command handling middleware allows a command router to define middleware modules that are executed before, and after success or failure of each command dispatch ([#12](https://github.com/commanded/commanded/issues/12)).

---

## v0.6.3

### Enhancements

- Process manager instance processes event non-blocking to prevent timeout during event processing and any command dispatching. It persists last seen event id to ensure events are handled only once.

## v0.6.2

### Enhancements

- Command dispatch timeout. Allow a `timeout` value to be configured during command registration or dispatch. This overrides the default timeout of 5 seconds. The same as the default `GenServer` call timeout.

### Bug fixes

- Fix pending aggregates restarts: supervisor restarts aggregate process but it cannot accept commands ([#22](https://github.com/commanded/commanded/pull/22)).

## v0.6.1

### Enhancements

- Upgrade `eventstore` mix dependency to v0.6.0 to use support for recorded events created_at as `NaiveDateTime`.

## v0.6.0

### Enhancements

- Confirm receipt of events in event handler and process manager router ([#19](https://github.com/commanded/commanded/pull/19)).
- Convert keys to atoms when decoding JSON using Poison decoder.
- Prefix process manager instance snapshot uuid with process manager name.
- Multi command dispatch registration in router ([#16](https://github.com/commanded/commanded/issues/16)).

---

## v0.5.0

### Enhancements

- Include event metadata as second argument to event handlers. An event handler must now implement the `Commanded.Event.Handler` behaviour consisting of a single `handle_event/2` function.

---

## v0.4.0

### Enhancements

- Macro to assist with building process managers ([README](https://github.com/commanded/commanded/tree/feature/process-manager-macro#process-managers)).

---

## v0.3.1

### Enhancements

- Include unit test event assertion function: `assert_receive_event/2` ([#13](https://github.com/commanded/commanded/pull/13)).
- Include top level application in mix config.

## v0.3.0

### Enhancements

- Don't persist an aggregate's pending events when executing a command returns an error ([#10](https://github.com/commanded/commanded/pull/10)).

### Bug fixes

- Ensure an aggregate's pending events are persisted in the order they were applied.

---

## v0.2.1

### Enhancements

- Support integer, atom or strings as an aggregate UUID ([#7](https://github.com/commanded/commanded/pull/7)).

## v0.1.0

Initial release.

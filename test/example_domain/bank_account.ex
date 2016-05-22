defmodule Commanded.ExampleDomain.BankAccount do
  use EventSourced.AggregateRoot, fields: [account_number: nil, balance: 0]

  alias Commanded.ExampleDomain.BankAccount

  defmodule Commands do
    defmodule OpenAccount do
      defstruct aggregate: BankAccount, aggregate_uuid: UUID.uuid4, account_number: nil, initial_balance: nil
    end

    defmodule DepositMoney do
      defstruct aggregate: BankAccount, aggregate_uuid: nil, amount: nil
    end

    defmodule WithdrawMoney do
      defstruct aggregate: BankAccount, aggregate_uuid: nil, amount: nil
    end
  end

  defmodule Events do
    defmodule BankAccountOpened do
      defstruct account_number: nil, initial_balance: nil
    end

    defmodule MoneyDeposited do
      defstruct transfer_uuid: nil, amount: nil, balance: nil
    end

    defmodule MoneyWithdrawn do
      defstruct transfer_uuid: nil, amount: nil, balance: nil
    end
  end

  alias Events.{BankAccountOpened,MoneyDeposited,MoneyWithdrawn}

  def open_account(%BankAccount{} = account, account_number, initial_balance) when initial_balance > 0 do
    account
    |> update(%BankAccountOpened{account_number: account_number, initial_balance: initial_balance})
  end

  def deposit(%BankAccount{} = account, amount) when amount > 0 do
    balance = account.state.balance + amount

    account
    |> update(%MoneyDeposited{amount: amount, balance: balance})
  end

  def withdraw(%BankAccount{} = account, amount) when amount > 0 do
    balance = account.state.balance - amount

    account
    |> update(%MoneyWithdrawn{amount: amount, balance: balance})
  end

  # event handling callbacks that mutate state

  def apply(%BankAccount.State{} = state, %BankAccountOpened{} = account_opened) do
    %BankAccount.State{state |
      account_number: account_opened.account_number,
      balance: account_opened.initial_balance
    }
  end

  def apply(%BankAccount.State{} = state, %MoneyDeposited{} = money_deposited) do
    %BankAccount.State{state |
      balance: money_deposited.balance
    }
  end

  def apply(%BankAccount.State{} = state, %MoneyWithdrawn{} = money_withdrawn) do
    %BankAccount.State{state |
      balance: money_withdrawn.balance
    }
  end
end

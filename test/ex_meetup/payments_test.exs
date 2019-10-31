defmodule ExMeetup.PaymentsTest do
  use ExMeetup.DataCase

  alias ExMeetup.Payments

  describe "payments" do
    alias ExMeetup.Payments.Payment

    @valid_attrs %{amount: "120.5", currency: "some currency", state: "some state", value_date: ~D[2010-04-17]}
    @update_attrs %{amount: "456.7", currency: "some updated currency", state: "some updated state", value_date: ~D[2011-05-18]}
    @invalid_attrs %{amount: nil, currency: nil, state: nil, value_date: nil}

    def payment_fixture(attrs \\ %{}) do
      {:ok, payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_payment()

      payment
    end

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      assert {:ok, %Payment{} = payment} = Payments.create_payment(@valid_attrs)
      assert payment.amount == Decimal.new("120.5")
      assert payment.currency == "some currency"
      assert payment.state == "some state"
      assert payment.value_date == ~D[2010-04-17]
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{} = payment} = Payments.update_payment(payment, @update_attrs)
      assert payment.amount == Decimal.new("456.7")
      assert payment.currency == "some updated currency"
      assert payment.state == "some updated state"
      assert payment.value_date == ~D[2011-05-18]
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end
end

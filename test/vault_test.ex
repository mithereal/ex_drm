defmodule Encryption.VaultTest do
  use ExUnit.Case

  test "decrypt/1 ciphertext that was encrypted with default key" do
    plaintext = "hello" |> AES.encrypt() |> AES.decrypt()
    assert plaintext == "hello"
  end
  end
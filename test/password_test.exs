defmodule Encryption.PasswordFieldTest do
    use ExUnit.Case
    alias Encryption.PasswordField, as: Field
  
    test "hash_password/1 uses Argon2id to Hash a value" do
      password = "EverythingisAwesome"
      hash = Field.hash_password(password)
      verified = Argon2.verify_pass(password, hash)
      assert verified
    end
  
  end
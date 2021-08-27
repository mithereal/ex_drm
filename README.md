# Drm

**About: Drm License server responsible for generating licenses**


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `drm` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:drm, "~> 0.2.0"}
  ]
end
```

## Usage

config.exs
config :drm,
 allow_burner_emails: true,
 validation_interval: 2000,  
 max_floats: 5, 
 path: Path.expand("../priv/license", __DIR__),  
 refresh_interval: 2000,
 key: "yyyyy",
 salt: "xxxx"

config :drm, Encryption.Vault, ciphers: [
default: { Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!(System.get_env("ENCRYPTION_KEY")), iv_length: 12 }
]


## Generating a license

iex> license = %{hash: "license-key12", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "
policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil,
max_fingerprints: nil, fingerprint: "umbrella-app-hash-id"}} 

iex> License.create(license)

iex> License.fingerprint_valid?(license.policy.fingerprint)

This will also create an encrypted key file on the filesystem you can decide if/how you want to distribute it.

[![Build Status](https://travis-ci.org/mithereal/ex_drm.svg?branch=master)](https://travis-ci.org/mithereal/ex_drm)

[![Inline docs](http://inch-ci.org/github/mithereal/elixir_drm.svg)](http://inch-ci.org/github/mithereal/ex_drm)


<a href="https://www.buymeacoffee.com/am8IcVA" target="_blank"><img src="https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found
at [https://hexdocs.pm/license](https://hexdocs.pm/license).


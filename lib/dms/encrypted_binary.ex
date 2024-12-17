defmodule Dms.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Dms.Vault
end

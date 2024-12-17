defmodule Dms.Repo.Migrations.ModifyReceiverIdNullable do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :receiver_id, :integer, null: true
    end
  end
end

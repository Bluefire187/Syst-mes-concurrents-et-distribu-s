defmodule Dms.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :binary #car on utilise cloak pour chiffrer
      add :sender_id, :integer
      add :receiver_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end

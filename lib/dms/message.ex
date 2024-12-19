defmodule Dms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, Dms.Encrypted.Binary
    field :sender_id, :integer
    field :receiver_id, :integer
    belongs_to :user, Dms.User

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :sender_id, :receiver_id, :user_id])
    |> validate_required([:content, :sender_id])
    |> validate_length(:content, min: 1, max: 500)
  end
end

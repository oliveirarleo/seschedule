defmodule Seschedule.Api.Event do
  @enforce_keys [:id, :title, :first_session, :last_session, :link]
  defstruct [
    :id,
    :title,
    :first_session,
    :last_session,
    :link,
    complement: "",
    image_link: "",
    unit: [],
    categories: [],
    cancelado: false,
    num_tickets_web: 0,
    num_tickets_local: 0
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          first_session: DateTime.t(),
          last_session: DateTime.t(),
          link: String.t(),
          complement: String.t(),
          image_link: String.t(),
          unit: [{String.t(), String.t()}],
          categories: [{String.t(), String.t()}],
          cancelado: boolean(),
          num_tickets_web: integer() | nil,
          num_tickets_local: integer() | nil
        }
end

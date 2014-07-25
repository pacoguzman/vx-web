class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :state, :created_at, :amount
end

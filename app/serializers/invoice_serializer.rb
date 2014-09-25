class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :status, :status_name, :created_at, :amount, :amount_string
end

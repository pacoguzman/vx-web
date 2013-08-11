require 'spec_helper'

describe UserIdentity do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: user_identities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string(255)      not null
#  token      :string(255)      not null
#  uid        :string(255)      not null
#  login      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#


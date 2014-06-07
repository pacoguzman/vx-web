UserSignup = Struct.new(:company_name, :email, :omniauth) do

  def create
    User.transaction do
      if user.valid? and company.valid?
        user.add_to_company(company)
      else
        rollback
      end
    end
  end

  def valid?
    user.valid? and company.valid?
  end

  def user
    @user ||= begin
      github = UserSession::Github.new(omniauth)
      github.create email
    end
  end

  def company
    @company ||= begin
      c = Company.new name: company_name
      c.save
      c
    end
  end

  private

    def rollback
      raise ActiveRecord::Rollback
    end

end

UserSignup = Struct.new(:company_name, :email, :omniauth) do

  def create
    User.transaction do
      if user and company and valid?
        user.add_to_company(company, role: company.default_user_role) || rollback
      else
        rollback
      end
    end
  end

  def user_exists?
    !!github.find
  end

  def github
    @github ||= UserSession::Github.new(omniauth)
  end

  def valid?
    user.valid? and company.valid?
  end

  def errors
    rs = []
    user.errors.full_messages.each do |e|
      rs << "User #{e}"
    end
    company.errors.full_messages.each do |e|
      rs << "Company #{e}"
    end
    rs
  end

  def user
    @user ||= begin
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

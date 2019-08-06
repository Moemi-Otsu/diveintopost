class OwnerMailer < ApplicationMailer
  def owner_mail(email, team_name)
    @email = email
    @team_name = team_name
    mail to: @email, subject: 'オーナー権限移譲'
  end
end

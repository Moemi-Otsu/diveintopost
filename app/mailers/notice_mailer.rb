class NoticeMailer < ApplicationMailer
  def notice_mail(team_members_email)
    mail to: team_members_email.join(", "), subject: "チーム内アジェンダ削除のお知らせ"
  end
end

class AssignsController < ApplicationController
  before_action :authenticate_user!

  def create
    team = Team.friendly.find(params[:team_id])
    user = email_reliable?(assign_params) ? User.find_or_create_by_email(assign_params) : nil
    if user
      team.invite_member(user)
      redirect_to team_url(team), notice: 'アサインしました！'
    else
      redirect_to team_url(team), notice: 'アサインに失敗しました！'
    end
  end

  def destroy
    assign = Assign.find(params[:id])
    destroy_message = assign_destroy(assign, assign.user)

    redirect_to team_url(params[:team_id]), notice: destroy_message
  end

  private

  def assign_params
    params[:email]
  end

  def assign_destroy(assign, assigned_user)
    if assigned_user == assign.team.owner
      'リーダーは削除できません。'
    elsif Assign.where(user_id: assigned_user.id).count == 1
      'このユーザーはこのチームにしか所属していないため、削除できません。'
    # チームオーナーはチームリーダー以外のメンバーを削除可能
    elsif current_user == assign.team.owner
      assign.destroy
      set_next_team(assign, assigned_user)
      'メンバーを削除しました。'
    # ユーザーは自分のアカウントのみ削除可能。それ以外のメンバーは削除不可能。
    elsif current_user != assigned_user
      'ユーザー本人以外のアカウントを削除することはできません。'
    elsif assign.destroy
      set_next_team(assign, assigned_user)
      'メンバーを削除しました。'
    else
      'なんらかの原因で、削除できませんでした。'
    end
  end  
  
  def email_reliable?(address)
    address.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end
  
  def set_next_team(assign, assigned_user)
    another_team = Assign.find_by(user_id: assigned_user.id).team
    change_keep_team(assigned_user, another_team) if assigned_user.keep_team_id == assign.team_id
  end
end

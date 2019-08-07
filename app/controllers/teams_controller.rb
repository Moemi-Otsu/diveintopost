class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
    if current_user != @team.owner
      redirect_to team_path(@team.id), notice: 'チームオーナー以外のユーザーはチーム情報を編集することができません。'
    end
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :new
    end
  end

  def update
    if @team.update(team_params)
      # オーナー権限が変更されていた場合はメール送信
      if team_params.include?("name")
      else
        new_owner_user = User.find(team_params[:owner_id])
        @email = new_owner_user.email
        @team_name = @team.name
        OwnerMailer.owner_mail(@email, @team_name).deliver
      end
      redirect_to @team, notice: 'チーム更新に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'チーム削除に成功しました！'
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end

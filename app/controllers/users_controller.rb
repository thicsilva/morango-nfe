class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  #bloqueando o acesso sem estar logado
  before_action :must_login, only: [:index, :show, :edit, :update, :destroy, :new]
  #verifica se o usuario é um usuario simples e bloqueia se tentar acessar as configurações de todos usuarios via url
  before_action :check_user_logged, only: [:index]


  #chama a edição do usuario que está logado
  def chama_edicao
     @id_user = current_user.id
    redirect_to edit_user_path(@id_user)
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.limit(10)
    @total_users = User.count

    if params[:search] && params[:tipo_consulta] == "1"
          @users = User.where("name like ?", "%#{params[:search]}%")

            elsif params[:search] && params[:tipo_consulta] == "2"
                @users = User.where("email like ?", "%#{params[:search]}%")

        end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
              #Sends email to user when user is created.
      UserNotifier.send_signup_email(@user).deliver_now
        format.html { redirect_to @user }
        flash[:success] = 'Usuário criado com sucesso, os dados foram enviados para o email informado.'
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Usuário atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Usuário excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :type_access,:ccli,:cforn,:cprod,:ccateg,:cvend,:cuser,:mos,:fpag,:frec,:rcli,:rforn,:rprod,:rpag,:rrec,:mupload, :rcateg, :rvend, :rfecha, :minput,:shipping,:mconsul_nfe, :mcancel_number,:rnfe, :c_route, :r_compra)
    end

    #verifica o perfil do usuario
    def check_user_logged
      if current_user.type_access == 'User'
        flash[:danger] = 'Voçê não tem permissão para acessar essa pagina!'
        redirect_to root_path
      end
    end

end

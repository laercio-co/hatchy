module Hatchy
  class Admin::ProjectsController < Admin::ApplicationController
    before_action :set_project, only: [:edit, :show, :update, :destroy]
    
    # GET /projects
    def index
      respond_to do |format|
        format.html
        format.json { render json: Hatchy::ProjectsDatatable.new(view_context) }
      end
    end

    # GET /project/:id
    def show
    end

    # GET /project/:id/edit
    def edit
    end

    # PATCH /project/:id
    # PUT /project/:id
    def update
      respond_to do |format|
        if @project.update_attributes(project_params)
          format.html {redirect_to admin_project_path(@project), notice:t('controllers.hatchy.admin.projects.create.notice')}
          format.json {head :ok}
        else
          format.html {render :show, flash[:error] = @project.errors.full_messages.to_sentence}
          format.json {render json: @project.errors.full_messages.to_sentence, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      if @project.trash?
        @project.destroy
        redirect_to admin_projects_path
        flash[:notice] = t('controllers.hatchy.admin.projects.destroy.notice')
      else
        redirect_to admin_project_path(@project)
        flash[:error] = t('controllers.hatchy.admin.projects.destroy.status_trash')
      end
    end

    [:send_to_approved, :push_to_online, :send_to_rejected, :send_to_draft, :push_to_trash, :send_to_successful].each do |m|
      define_method m do 
        set_project
        @project.send("#{m}")
        if @project.errors.empty?
          @project.save
          redirect_to admin_project_path(@project), notice: "Project was #{m.to_s.humanize}."
        else
          redirect_to admin_project_path(@project)
          flash[:error] = @project.errors.full_messages.to_sentence
        end
      end
    end

    private
    def set_project
      @project = Hatchy::Project.find(params[:id])
    end

    def project_params
      params[:project].permit(
        :name, :status, :recommended,
        
        account_attributes:[
          :account,       :account_digit,     :account_type,
          :address_city,  :address_number,    :address_state,
          :address_street,:address_zip,       :bank_id,           
          :email,         :owner_document,    :owner_name,
          :phone,         :project_id,        :id
        ]
      )
    end
  end
end
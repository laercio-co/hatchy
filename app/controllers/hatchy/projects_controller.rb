module Hatchy
  class ProjectsController < ApplicationController
    skip_before_filter :authenticate_user!, only: [:show]
    before_action :set_project, only: [:edit, :show, :update, :send_to_analysis, :publish]
    after_action :verify_authorized, except:[:show]
    
    # GET /projects/new
    def new
      @project = Hatchy::Project.new(user: current_user)
      authorize @project
    end

    # GET /projects/:id/edit
    def edit
      authorize @project
      @layout_footer = false
      @project.rewards.build
      @project.build_account unless @project.account
    end

    # GET /projects/:id
    def show
      if current_user
        if @project.user == current_user || current_user.admin?
          unless params[:preview]
            redirect_to edit_project_path(@project, anchor:'basic')
          end
          flash[:notice] = t('controllers.hatchy.projects.show.project_status') + ": #{@project.status}"
        end
      end
    end

    # POST /projects
    def create
      @project = Hatchy::Project.new(project_params)
      @project.user = current_user
      authorize @project
      if @project.valid?
        @project.save
        redirect_to edit_project_path(@project, anchor: 'basic'), notice:t('controllers.hatchy.projects.create.notice')
      else
        render :new
      end
    end

    # PATCH /projects/:id
    # PUT /projects/:id
    def update
      authorize @project
      if @project.update(project_params)
        redirect_to edit_project_path(@project, anchor: params[:anchor]), notice:t('controllers.hatchy.projects.update.notice')
      else
        redirect_to edit_project_path(@project, anchor: params[:anchor])
        flash[:error] = @project.errors.full_messages.to_sentence
      end
    end

    def send_to_analysis
      authorize @project
      @project.send_to_analysis
      if @project.valid?
        @project.save
        redirect_to edit_project_path(@project, anchor:'analysis_success')
      else
        redirect_to edit_project_path(@project, anchor:'basic')
        flash[:error] = @project.errors.full_messages.to_sentence
      end
    end

    def publish
      authorize @project
      @project.push_to_online
      if @project.valid?
        @project.save
        redirect_to project_path(@project), notice:t('controllers.hatchy.projects.publish.notice')
      else
        redirect_to edit_project_path(@project, anchor:'basic')
        flash[:error] = @project.errors.full_messages.to_sentence
      end
    end

    private

    def set_project
      @project = Hatchy::Project.find(params[:id])
    end

    def project_params
      if @project
       params[:project].permit(@project.safe_params)
      else
        params[:project].permit(:name, :category_id)
      end
    end

  end
end

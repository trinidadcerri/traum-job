class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def employer_index
    if current_user.job_seeker == true
      redirect_to jobs_path, notice: "You are not authorized to access this page"
    end
    if params[:query].present?
      @users = User.where.not(id: current_user.id).where.not(job_seeker: false).search_by_profesion_and_location(params[:query])
    else
      @users = User.where.not(id: current_user.id).where.not(job_seeker: false)
    end
  end

  def candidates_show
    @user = User.find(params[:id])
    if current_user.job_seeker == true
      redirect_to jobs_path, notice: "You are not authorized to access this page"
    end
  end

  def dashboard
    if current_user.job_seeker == false
      redirect_to candidates_path, notice: "You are not authorized to access this page"
    end
    @favorites = Favorite.where(user: current_user)
  end

  def cvs
    @cvs = current_user.cvs
  end

  def calendar
    # @appointments = Appointment.all
    start_date = params.fetch(:date, Date.today).to_date
    @appointments = current_user.job_applications.includes(job: :appointments).where(status: "accepted").flat_map(&:job).flat_map(&:appointments).select { |appointment| appointment.date.between?(start_date.beginning_of_month.beginning_of_week, start_date.end_of_month.end_of_week) }.uniq
  end

  def employer_calendar
    start_date = params.fetch(:date, Date.today).to_date
    jobs_appointments = current_user.jobs.includes(:appointments).where(appointments: {date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week})
    @appointments = jobs_appointments.map(&:appointments).flatten
  end

  def employer_profile
    if current_user.job_seeker == true
      redirect_to jobs_path, notice: "You are not authorized to access this page"
    else
      @jobs = Job.where(user: current_user)
    end
  end
end

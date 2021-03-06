class Admin::MaintenanceWindowsController < Admin::AdminController
  before_action :set_admin_maintenance_window, only: [:edit, :update]

  # GET /admin/maintenance_windows
  def index
    @admin_maintenance_windows = Admin::MaintenanceWindow.order(:enabled).reverse_order
  end

  # GET /admin/maintenance_windows/new
  def new
    @admin_maintenance_window = Admin::MaintenanceWindow.new
  end

  # GET /admin/maintenance_windows/1/edit
  def edit
  end

  # POST /admin/maintenance_windows
  def create
    @admin_maintenance_window = Admin::MaintenanceWindow.new(admin_maintenance_window_params)
    @admin_maintenance_window.user = current_user

    if @admin_maintenance_window.save
      flash[:success] = 'Maintenance window was successfully created.'
      redirect_to admin_maintenance_windows_path
    else
      flash[:error] = 'Create Maintenance window failed!'
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/maintenance_windows/1
  def update
    if @admin_maintenance_window.update(admin_maintenance_window_params)
      flash[:success] = 'Maintenance window was successfully updated.'
      redirect_to admin_maintenance_windows_path
    else
      flash[:error] = 'Update Maintenance window failed!'
      render action: 'edit'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_maintenance_window
    @admin_maintenance_window = Admin::MaintenanceWindow.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def admin_maintenance_window_params
    params.require(:admin_maintenance_window).permit(:name, :description, :message, :end_at, :enabled)
  end
end

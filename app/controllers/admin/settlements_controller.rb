class Admin::SettlementsController < Admin::AdminController
  filter_resource_access
  # todo: define nested resource
  filter_access_to [:new, :show, :create, :edit, :update], :require => :manage
  
  before_filter :load_parent_resources
  
  def index
    order = params[:order] ? params[:order] : {'order' => 'ascend_by_name'}
    @search = @municipality.settlements.with_permissions_to(:manage, :context => :admin_settlements).search(params[:search]).search(order)
    @settlements = @search.paginate(:page => params[:page])
  end
  
  def new
    @settlement = @municipality.settlements.new
  end

  def show
    @settlement = Settlement.find(params[:id])
  end

  def edit
    @settlement = Settlement.find(params[:id])
  end
  
  def create
    @settlement = @municipality.settlements.new(params[:settlement])
    if @settlement.save
      flash[:notice] = t('admin.settlements.create.notice')
      redirect_to admin_county_municipality_settlements_path(@county, @municipality)
    else
      flash.now[:error] = t('admin.settlements.create.error')
      render :action => :new
    end
  end

  def update
    @settlement = Settlement.find(params[:id])
    if @settlement.update_attributes(params[:settlement])
      flash[:notice] = t('admin.settlements.update.notice')
      redirect_to admin_county_municipality_settlements_path(@county, @municipality)
    else
      flash.now[:error] = t('admin.settlements.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    @settlement = Settlement.find(params[:id])
    if @settlement.destroy
      flash[:notice] = t('admin.settlements.destroy.notice')
    else
      flash.now[:error] = t('admin.settlements.destroy.error')
    end
    redirect_to admin_county_municipality_settlements_path(@county, @municipality)
  end
  

  private
  
  def load_parent_resources
    @county = County.find(params[:county_id])
    @municipality = Municipality.find(params[:municipality_id])
  end
end

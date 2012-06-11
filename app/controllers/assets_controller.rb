# coding: utf-8
class AssetsController < ApplicationController
  before_filter :find_asset, :only => [:edit, :update, :show]
  def index
    query = "select wt.short_name as short_name, a.cost as cost, a.part_number as part_number, a.name as name, 
      ag.name as group_name, a.budget_item_id as budget_item_id, a.id as id 
      from assets a
      join asset_groups ag on ag.id=a.asset_group_id
      join ware_types wt on wt.id=a.ware_type_id
      order by ag.name, a.name"
    @assets = Asset.find_by_sql(query)  
#    @assets = Asset.order(:asset_group_id, :name)
#    .paginate :page => params[:page], :per_page => 20
  end

  def show
  end
  
  def new
    @budget_items = BudgetItem.find_budget_items
    @groups = AssetGroup.get_full_groups
    @asset = Asset.new
  end

  def create
    @asset = Asset.new params[:asset]
    if not @asset.save
      render :new
    else
      redirect_to assets_path
    end
  end
  
  def edit
    @budget_items = BudgetItem.find_budget_items
    @groups = AssetGroup.get_full_groups
  end
  
  def update
    if not @asset.update_attributes params[:asset]
      render :action => :edit
    else
      redirect_to assets_path
    end
  end
private
  def find_asset
    @asset = Asset.find params[:id]
  end
end
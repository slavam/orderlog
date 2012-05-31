# coding: utf-8
class AssetsController < ApplicationController
  before_filter :find_asset, :only => [:edit, :update, :show]
  def index
    @assets = Asset.order(:name).paginate :page => params[:page], :per_page => 20
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
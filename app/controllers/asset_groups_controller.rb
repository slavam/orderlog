# coding: utf-8
class AssetGroupsController < ApplicationController
  before_filter :find_asset_group, :only => [:show, :edit, :update]      
  def index
    @groups = AssetGroup.order(:block_id,:name)
    #.paginate :page => params[:page], :per_page => 20
  end

  def show
      
  end
  
  def new
    @asset_group = AssetGroup.new
  end

  def create
    @asset_group = AssetGroup.new params[:asset_group]
    if not @asset_group.save
      render :new
    else
      redirect_to asset_groups_path
    end
  end
  
  def edit
    
  end
  def update
    if not @asset_group.update_attributes params[:asset_group]
      render :action => :edit
    else
      redirect_to asset_groups_path
    end
  end
private
  def find_asset_group
    @asset_group = AssetGroup.find params[:id] 
  end
end
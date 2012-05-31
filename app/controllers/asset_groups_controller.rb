# coding: utf-8
class AssetGroupsController < ApplicationController
  
  def index
    @groups = AssetGroup.order(:id).paginate :page => params[:page], :per_page => 20
  end

  def show
    @group = AssetGroup.find params[:id]  
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
end
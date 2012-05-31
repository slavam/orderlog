# coding: utf-8
class ServicesController < ApplicationController
  
  def index
    @services = Service.order(:name).paginate :page => params[:page], :per_page => 20
  end

  def show
    @service = Service.find params[:id]  
  end
  
  def new
    @service = Service.new
  end

  def create
    @service = Service.new params[:service]
    if not @service.save
      render :new
    else
      redirect_to services_path
    end
  end
  
end
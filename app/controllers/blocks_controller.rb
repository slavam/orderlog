# coding: utf-8
class BlocksController < ApplicationController
  before_filter :find_block, :only => [:show, :edit, :update]      
  def index
    @blocks = Block.order(:id)
  end

  def show
  end
  
  def new
    @block = Block.new
  end

  def create
    @block = Block.new params[:block]
    if not @block.save
      render :new
    else
      redirect_to blocks_path
    end
  end
  
  def edit
  end

  def update
    if not @block.update_attributes params[:block]
      render :action => :edit
    else
      redirect_to blocks_path
    end
  end
private
  def find_block
    @block = Block.find params[:id] 
  end
end
# coding: utf-8
class StatesController < ApplicationController
  
  def index
    @states = State.order(:document_type_id)
  end

  def show
    @state = State.find params[:id]  
  end
  
  def new
    @state = State.new
  end

  def create
    @state = State.new params[:state]
    if not @state.save
      render :new
    else
      redirect_to states_path
    end
  end
  
end
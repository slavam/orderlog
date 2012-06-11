# coding: utf-8
class ClaimLinesController < ApplicationController
  before_filter :find_claim_line, :only => [:show, :edit]  
#  def index
#    @claims = Claim.order(:claim_number)
#  end

  def show
  end
  
  def new
    @claim_line = ClaimLine.new
    @claim = Claim.find params[:claim_id]
    @budget_items = BudgetItem.find_budget_items
  end

  def create
    @claim_line = ClaimLine.new params[:claim_line]
    @claim_line.claim_id = params[:claim_id]
    a = Asset.find(@claim_line.asset_id)
    @claim_line.cost = a.cost ? a.cost : 0
    @claim_line.amount = @claim_line.count*@claim_line.cost
    @claim_line.budget_item_id = a.budget_item_id
    
    if not @claim_line.save
      render :new
    else
      redirect_to claim_path params[:claim_id]
    end
  end
  
  def edit
    @claim = Claim.find @claim_line.claim_id
    @budget_items = BudgetItem.find_budget_items
  end

  def update
#    claim_line = ClaimLine.find params[:claim_line_id]
#    claim_line.update_attributes params[:claim_line]
    claim_line = ClaimLine.find params[:id]
    claim_line.update_attributes params[:claim_line]
    claim_line.amount = claim_line.count*claim_line.cost
    
    claim_line.save
    redirect_to claim_path claim_line.claim_id
  end
private
  def find_claim_line
    @claim_line = ClaimLine.find params[:id]
  end
end

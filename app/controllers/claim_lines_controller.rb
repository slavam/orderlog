# coding: utf-8
class ClaimLinesController < ApplicationController
  
#  def index
#    @claims = Claim.order(:claim_number)
#  end

  def show
    @claim_line = ClaimLine.find params[:id]  
  end
  
  def new
    @claim_line = ClaimLine.new
#    @ware_type = params[:ware_type]
    @claim = Claim.find params[:claim_id]
  end

  def create
    @claim_line = ClaimLine.new params[:claim_line]
    @claim_line.claim_id = params[:claim_id]
#    w = Ware.find(@claim_line.ware_id)
    a = Asset.find(@claim_line.asset_id)
    @claim_line.amount = @claim_line.count*a.cost
    @claim_line.budget_item_id = a.budget_item_id
    @claim_line.ware_id = 1
#    if params[:ware_type] == 'asset'
#      a = Ware.find(@claim_line.ware_id).asset
#      @claim_line.budget_item_id = a.budget_item_id
#    else
#      s = Ware.find(@claim_line.ware_id).service
#      @claim_line.budget_item_id = s.budget_item_id
#    end  
    
    if not @claim_line.save
      render :new
    else
      redirect_to claim_path params[:claim_id]
    end
  end

  def update
    claim_line = ClaimLine.find params[:claim_line_id]
    claim_line.update_attributes params[:claim_line]
    w = Ware.find(claim_line.ware_id)
    claim_line.amount = claim_line.count*w.cost
    
    claim_line.save
    redirect_to claim_path claim_line.claim_id
  end
end
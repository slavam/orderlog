# coding: utf-8
class ClaimsController < ApplicationController
  FIN_OWNER = 'FIN'
  before_filter :find_claim, :only => [:show, :claim_state_change, :delete_claim, :claim_history, :edit]
  before_filter :find_claim_line, :only => [:change_budget_item, :edit_quantity, :edit_description]
  def index
    @claims = Claim.order(:create_date)
  end

  def show
    if @claim.state.state_name.name == "На согласовании"
#      lines = @claim.claim_lines.select(:budget_item_id).uniq
      @grouped_lines = @claim.claim_lines.select("budget_item_id, sum(amount) as item_sum, 'name' as name, 0 as limit").group(:budget_item_id)
      @grouped_lines.each {|l|
        query = "select value, bd.name as name from "+FIN_OWNER+".budget_value v
          join "+FIN_OWNER+".division d on d.id=v.division_id and d.id="+@claim.division_id.to_s+
          " join "+FIN_OWNER+".periods p on p.id=v.periods_id and p.id="+@claim.period_id.to_s+
          " join "+FIN_OWNER+".budget_directory bd on v.budget_factor_id=bd.id where v.budget_flag_correction_id = 1 and bd.id="+
          l[:budget_item_id].to_s
        bi = BudgetItem.find_by_sql(query).first
        l.name = BudgetItem.find(l[:budget_item_id]).name
        l.limit = (bi ? bi[:value]: 0)
#        l.name = (bi[0] ? bi[0][:name]: '')
#        l.limit = (bi[0] ? bi[0][:value]: 0)
        }
#      budget_item_ids = Array.new
#      lines.each {|bi| budget_item_ids << bi[:budget_item_id]}
#      @budget_items = BudgetItem.where("id in ("+budget_item_ids.join(',')+")")
#      p budget_item_ids.join(',')+">>>>>>>>>>>>>>>>>>>>>>>>"

#select sum(amount)
#from claim_lines cl
#where claim_id = 2
#group by budget_item_id
#
#      query ="
#        select * from "+FIN_OWNER+".budget_value v
#        join "+FIN_OWNER+".division d on d.id=v.division_id and d.code='003'
#        join "+FIN_OWNER+".periods p on p.id=v.periods_id and p.type_period='M' and p.date_from=to_date('01-04-2012','dd-mm-yyyy')
#        join "+FIN_OWNER+".budget_directory bd on v.budget_factor_id=bd.id and bd.id=532"
      render 'show_claim_on_agreement'
    end
  end
  
  def new
    @claim = Claim.new
  end

  def create
    @claim = Claim.new params[:claim]
    @claim.create_date = Time.now
    @claim.budgetary = true
    @claim.state_id = 1 # первичная заявка -> черновик
    if not @claim.save
      render :new
    else
      claim_history = ClaimHistory.new
      claim_history.claim_id = @claim.id
      claim_history.state_id = @claim.state_id
      claim_history.change_at = Time.now
      claim_history.save
      redirect_to claim_path @claim
    end
  end
  
  def delete_claim
   @claim.destroy
   redirect_to claims_path
  end
  
  def delete_claim_line
    @claim_line = ClaimLine.find params[:claim_line_id]
    claim_id = @claim_line.claim_id
    @claim_line.destroy
    redirect_to claim_path claim_id
  end
  
  def claim_state_change
    case @claim.state.state_name.name
      when "Черновик"
        new_state_id = State.find_by_document_type_id_and_state_name_id(
          DocumentType.find_by_name("Первичная заявка").id,
          StateName.find_by_name("На согласовании").id).id
      when "На согласовании"  
        new_state_id = State.find_by_document_type_id_and_state_name_id(
          DocumentType.find_by_name("Первичная заявка").id,
          StateName.find_by_name("Согласовано").id).id
    end
    @claim.update_attribute('state_id', new_state_id)
    @claim.save
    claim_history = ClaimHistory.new
    claim_history.claim_id = @claim.id
    claim_history.state_id = @claim.state_id
    claim_history.change_at = Time.now
    claim_history.save
    redirect_to claims_path
  end

  def change_budget_item
    @budget_items = BudgetItem.find_budget_items
  end
  
  def edit_quantity
  end
  
  def claim_history
    @history_lines = ClaimHistory.where("claim_id=?", params[:id]).order(:change_at)
  end
  
  def edit_description
  end

  def get_consolidated_climes_params
    @claim = Claim.new
  end

  def show_claim_consolidated
    @period = Period.find params[:claim_params][:period_id]
    @direction = Direction.find params[:claim_params][:direction_id]
    claims = Claim.select("distinct(division_id)").where("state_id=2 and period_id=? and direction_id=?",@period.id, @direction.id)
    division_ids = []
    claims.each {|d| division_ids << d.division_id}
    query = "select sum(cl.count) as quantity, sum(cl.amount) as amount, cl.budget_item_id, '' as article, 0 as limit from claims c
      join claim_lines cl on cl.claim_id=c.id
      where c.direction_id = "+@direction.id.to_s+" and period_id="+@period.id.to_s+" and c.state_id = 2
      group by cl.budget_item_id"
    @claim_lines = Claim.find_by_sql(query)
    @claim_lines.each {|cl|
      query ="select sum(bv.value) as limit from FIN.budget_value bv
        join FIN.budget_directory bd on bd.id=bv.budget_factor_id
        join FIN.division d on d.id=bv.division_id
          and d.id in ("+division_ids.join(',')+")
        join FIN.periods p on p.id=bv.periods_id 
          and p.id="+@period.id.to_s+"
      where bv.budget_factor_id="+cl.budget_item_id.to_s+"
        and bv.budget_flag_correction_id = 1
      group by bd.name"
      budget_limit = BudgetItem.find_by_sql(query).first
      b_i = BudgetItem.select("name, id").find cl.budget_item_id
      cl.article = b_i.name
      cl.budget_item_id = b_i.id
      cl.limit = (budget_limit ? budget_limit.limit : 0)
    }
  end
  
  def show_claim_lines_by_budget_item
    @article = BudgetItem.find params[:budget_item_id]
    query = "select * from claim_lines cl
      join claims c on c.id=cl.claim_id and c.state_id=2 and c.period_id="+params[:period_id]+
      " and c.direction_id="+params[:direction_id]+ 
      " where budget_item_id="+params[:budget_item_id]
    @claim_lines = ClaimLine.find_by_sql(query)
  end
private
  def find_claim_line
    @claim_line = ClaimLine.find params[:claim_line_id]
  end
  def find_claim
    @claim = Claim.find params[:id]
  end    

end
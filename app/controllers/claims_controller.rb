# coding: utf-8
class ClaimsController < ApplicationController
  FIN_OWNER = 'FIN'
  before_filter :find_claim, :only => [:show, :claim_state_change, :delete_claim, :claim_history, :edit, :update]
  before_filter :find_claim_line, :only => [:change_budget_item, :edit_quantity, :edit_description]
  def index
    @claims = Claim.order(:period_id, :direction_id, :division_id, :id)
  end

  def show
    if (@claim.state.state_name.name == "На согласовании") or (@claim.state.state_name.name == "Согласовано")
      @grouped_lines = @claim.claim_lines.select("budget_item_id, sum(amount) as item_sum, 'name' as name, 0 as limit").group(:budget_item_id)
      @grouped_lines.each {|l|
        if l[:budget_item_id]!=0
          query = "select value*bd.sign as value, bd.name as name from "+FIN_OWNER+".budget_value bv
            join "+FIN_OWNER+".budget_factor bf on bf.id=bv.budget_factor_id
            join "+FIN_OWNER+".budget_directory bd on bd.id=bf.budget_directory_id and bd.budget_groups_id in (7,9)
            -- join FIN.budget_business bb on bb.id=bf.budget_business_id
            where bv.budget_flag_correction_id=1 and bv.division_id="+@claim.division_id.to_s+
            " and bv.periods_id="+@claim.period_id.to_s+" and bd.id="+l[:budget_item_id].to_s
          bi = BudgetItem.find_by_sql(query).first
          l.name = BudgetItem.find(l[:budget_item_id]).name
          l.limit = (bi ? bi[:value]: 0)
        else
          l.name = "Без статьи бюджета"
          l.limit = 0
        end  
      }
      render 'show_claim_on_agreement'
    end
  end
  
  def new
    @claim = Claim.new
  end

  def create
    params[:claim][:create_date] = Time.now
    @claim = Claim.create(params[:claim])
    @claim.budgetary = true
    @claim.state_id = 1 # первичная заявка -> черновик
    @claim.claim_number = @claim.direction.stamp+@claim.id.to_s
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
  
  def edit
  end

  def update
    @claim.update_attributes params[:claim]
    
    if not @claim.save
      render :edit
    else
      redirect_to claims_path
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
      query = "select sum(bv.value*bd.sign) as limit from FIN.budget_value bv
        join FIN.budget_factor bf on bf.id=bv.budget_factor_id
        join FIN.budget_directory bd on bd.id=bf.budget_directory_id and bd.budget_groups_id in (7,9)
        -- join FIN.budget_business bb on bb.id=bf.budget_business_id
        where bv.budget_flag_correction_id=1 and bv.division_id in ("+division_ids.join(',')+") and bv.periods_id="+@period.id.to_s
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
  
  def show_limits
    @claim = Claim.find params[:claim_id]
    budget_item_ids = [] 
    @claim.claim_lines.each {|cl| budget_item_ids << cl.budget_item_id}
    b_i_ids = budget_item_ids.join(',')
#    @division = BranchOfBank.find claim.division_id
#    @period = Period.find claim.period_id
    query = "select bv.value*bd.sign as limit, bd.name as article, bb.name as business, bd.code as code 
      from "+FIN_OWNER+".budget_value bv
      join "+FIN_OWNER+".budget_factor bf on bf.id=bv.budget_factor_id
      join "+FIN_OWNER+".budget_directory bd on bd.id=bf.budget_directory_id and bd.budget_groups_id in (7,9) and
        bd.id in ("+b_i_ids+")
      join "+FIN_OWNER+".budget_business bb on bb.id=bf.budget_business_id
      where bv.budget_flag_correction_id=1 and bv.division_id="+
      @claim.division_id.to_s+" and bv.periods_id="+@claim.period_id.to_s
    @limits = BudgetItem.find_by_sql(query)
  end
private
  def find_claim_line
    @claim_line = ClaimLine.find params[:claim_line_id]
  end
  def find_claim
    @claim = Claim.find params[:id]
  end    
=begin
select * from FIN.budget_value bv
join FIN.budget_factor bf on bf.id=bv.budget_factor_id
join FIN.budget_directory bd on bd.id=bf.budget_directory_id and bd.budget_groups_id in (7,9)
join FIN.budget_business bb on bb.id=bf.budget_business_id
where bv.budget_flag_correction_id=1 and bv.division_id=3 and bv.periods_id=1846
-- использовать поле sign => bv.value*bd.sign  

Рекурсия для Postgresql

WITH RECURSIVE temp1 ( id, parent_id, name, PATH, LEVEL ) AS (
SELECT T1.id, T1.parent_id, T1.name, CAST (T1.id AS VARCHAR(50)) as PATH, 1
    FROM groups T1 WHERE T1.parent_id IS NULL
union
select T2.id, T2.parent_id, T2.name, CAST ( temp1.PATH ||'->'|| T2.id AS VARCHAR(50)) ,LEVEL + 1
     FROM groups T2 INNER JOIN temp1 ON( temp1.id= T2.parent_id)      )
select * from temp1 ORDER BY PATH LIMIT 100
=end
end
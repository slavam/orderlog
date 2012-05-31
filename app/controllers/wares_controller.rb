# coding: utf-8
class WaresController < ApplicationController
  
  def index
    @wares = Ware.order(:ware_type_id).paginate :page => params[:page], :per_page => 20
  end

  def show
    @ware = Ware.find params[:id]  
  end
  
  def new
    @ware = Ware.new
    @ware_type = params[:ware_type]
  end

  def create
    @ware = Ware.new params[:ware]
    if @ware.asset_id
      @ware.ware_type_id = 1
    else  
      @ware.ware_type_id = 2
    end
    if not @ware.save
      render :new
    else
      redirect_to wares_path
    end
  end
=begin
select * from FIN.budget_value v
join FIN.division d on d.id=v.division_id and d.code='003'
join FIN.periods p on p.id=v.periods_id and p.type_period='M' and p.date_from=to_date('01-04-2012','dd-mm-yyyy')
join FIN.budget_directory bd on v.budget_factor_id=bd.id 
and bd.id=532
===============================================================
SELECT t.id,
        LPAD(' ', (LEVEL*2 - 1) * 2) || t.name as descr,
        t.code,
        t.parent_id,
        CONNECT_BY_ISLEAF AS ISLEAF,
        CONNECT_BY_ROOT NAME AS ROOT
FROM FIN.budget_directory t
CONNECT BY NOCYCLE  PRIOR t.ID = t.PARENT_ID
start with t.PARENT_ID =488
and t.code like 'NR%'
ORDER SIBLINGS BY t.name;
  
=end  
  
end
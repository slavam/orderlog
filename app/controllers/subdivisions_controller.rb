# coding: utf-8
class SubdivisionsController < ApplicationController
  before_filter :find_department, :only => [:show, :edit, :update, :show_branches_of_division]
  before_filter :find_parent, :only => :show_branches_of_division
  def index
    @subdivisions = Subdivision.select([:id_division, :parent_id, :division, :code_division]).
      order(:id_division).paginate :page => params[:page], :per_page => 20
  end
  
  def show
    query = "
      with Hierachy(id_division, parent_id, division, Level)
      as
      (
      select id_division, parent_id, division, 0 as Level
          from div2doc c
          where c.id_division = "+params[:id]+"
          union all
          select c.id_division, c.parent_id, c.division, ch.Level + 1
          from div2doc c
          inner join Hierachy ch
          on ch.parent_id = c.id_division
      )
      select id_division, parent_id, division
      from Hierachy
      where Level >= 0 order by Level desc"
    @componames = Subdivision.find_by_sql(query)
#    @full_name = ""
#    @componames.each {|r| @full_name += r.division+" => "}
#    @full_name = @full_name[0, @full_name.size-4]
  end

  def show_branches_of_division
    @branches = Subdivision.select([:id_division, :parent_id, :division, :code_division]).where("parent_id = ?", params[:id]).
      order(:id_division).paginate :page => params[:page], :per_page => 20
  end

  private
  def find_department
    @department = Subdivision.select([:id_division, :parent_id, :division, :code_division]).where("id_division=?", params[:id]).first
  end
  def find_parent
    @parent = Subdivision.select([:id_division, :parent_id, :division, :code_division]).where("id_division=?", @department.parent_id).first
  end
end
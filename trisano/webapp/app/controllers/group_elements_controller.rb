class GroupElementsController <  AdminController

  def index
    @group_elements = GroupElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group_elements }
    end
  end

  def show
    @group_elements = GroupElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group_elements }
    end
  end

  def new
    begin
      @group_element = GroupElement.new
      @reference_element = FormElement.find(params[:form_element_id])      
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the group form  at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @group_element = GroupElement.find(params[:id])
  end
  
  def create
    @group_element = GroupElement.new(params[:group_element])
    @reference_element = FormElement.find(params[:reference_element_id])      

    begin
      @group_element.save_and_add_to_form
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the group form  at this time.'
      render :template => 'rjs-error'
    end
  end

  def update
    @group_element = GroupElement.find(params[:id])

    respond_to do |format|
      if @group_element.update_attributes(params[:group_element])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_element = GroupElement.find(params[:id])
    @group_element.destroy

    respond_to do |format|
      format.html { redirect_to(group_elements_url) }
      format.xml  { head :ok }
    end
  end
end
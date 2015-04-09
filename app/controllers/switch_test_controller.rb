class SwitchTestController < ApplicationController
   
  def index 	
  	@model_switches = Switch::MODEL_SWITCHES
  	@name_comports = Switch::NAME_COMPORTS
  	@name_tty = Switch::NAME_TTY
  end

  def work
    @switch = Switch.new
    @result = @switch.input_date_processing(article_params)
    respond_to do |format|
      format.js   {}
      format.json { render json: @result, status: :ok, location: root_path }
    end
  end

  def status_result 
    data = {result:Switch.read_status(params[:name_comport])}   
    render :json => data, status: :ok
  end

  def logging
    Switch.logging(params[:tty], params[:result], params[:name_comport], params[:model_switch])
    data = {result: "ok"}
    render :json => data, status: :ok
  end

private

  def article_params
  	params.require(:work).permit().tap do |whitelisted|
      Switch::NAME_COMPORTS.each do |comport|
        whitelisted[comport] = params[:work][comport]
      end
    end
  end

end

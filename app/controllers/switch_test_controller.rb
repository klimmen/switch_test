class SwitchTestController < ApplicationController
   
   def index 	
  	@model_switches = Switch::MODEL_SWITCHES
  	@name_comports = Switch::NAME_COMPORTS
  	@name_tty = Switch::NAME_TTY
  	@switch_tty = Switch::SWITCH_TTY
  end

  def work
    swith = Switch.new(article_params)
    redirect_to root_path
  end

private

  def article_params
  	params.require(:work).permit().tap do |whitelisted|
      Switch::NAME_TTY.each do |tty|
        whitelisted[tty] = params[:work][tty]
      end
    end
  end

end

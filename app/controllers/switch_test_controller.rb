class SwitchTestController < ApplicationController
  SWITCHES = ["zyxel2024", "zyxel3124", "zyxel3528"]
  COMPORT = [:a1, :a2, :a3, :a4, :b1, :b2, :b3, :b4]
  SWITSH_COMPORT = [:switch_a1, :switch_a2 ,:switch_a3, :switch_a4, :switch_b1, :switch_b2, :switch_b3, :switch_b4]  

  def index
  	@switches = SWITCHES
  	@comports = COMPORT
  	@swith_comport = SWITSH_COMPORT
  end

  def work
    p article_params
    redirect_to root_path(@switches)
  end

private
  def article_params
    params.require(:work).permit(*COMPORT, *SWITSH_COMPORT)

  end

end

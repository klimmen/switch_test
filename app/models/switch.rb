class Switch
  MODEL_SWITCHES = ["zyxel2024", "zyxel3124", "zyxel3528"]
  NAME_COMPORTS = [:a1, :a2, :a3, :a4, :b1, :b2, :b3, :b4]
  NAME_TTY      = [:S4, :S5, :S6, :S7, :S8, :S9, :S10, :S11]
  SWITCH_TTY    = [:switch_S4, :switch_S5 ,:switch_S6, :switch_S7,
                   :switch_S8, :switch_S9, :switch_S10, :switch_S11]   

  def initialize(switches_to_work) 
  	tty_switch = {}
    switches_to_work.each do |key, value|
	  if !value[key].nil?
	    tty_switch[key] = value["switch_#{key}".to_sym]
	  end
    end
    switch_to_work("S1","zyxel2024")
  end  


  def switch_to_work(tty, switch)
     model = switch.slice(/[a-z]+/i)
     case model
       when "zyxel" then zyxel = Zyxel.new; zyxel.work(tty, switch)
       when "zte" then zte = Zte.new; zte.work(tty, switch)
       when "dlink" then dlink = Dlink.new; dlink.work(tty, switch)
     end
  end    

end
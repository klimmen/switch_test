class Switch
  MODEL_SWITCHES = ["zyxel2024", "zyxel2108", "zyxel3124", "zyxel3500", "zyxel35008", "zyxel3528", "zte29xx", "zte29xxE"]
  NAME_COMPORTS = [:A1, :A2, :A3, :A4, :B1, :B2]
  NAME_TTY      = [:S4, :S5, :S6, :S7, :S8, :S9]

  def input_date_processing(switches_to_work) 
    `./restart_power`
  	tty_switch = []
    switches_to_work.each do |key, value| 
      if !value[key].nil?
        tty_switch << [key, value[key], value[value[key]]]
      end
    end
    tty_switch.map! do |value|
      #leep 0.2
      value << switch_to_work(value[0],value[1],value[2])
    end
    tty_switch
  end  

  def switch_to_work(name_comport, tty, switch)
    loading_time = {}
    File.open('log/result.log', 'w'){ |file| file.write "" }
    case switch        
      when /zte/
        model = Zte.new 
      when /zyxel/
        model = Zyxel.new
    end
    loading_time = model.timeout(switch)
    a = 1
    Thread.new do
      sleep a+=1
      f = File.new('log/result.log', 'a')
      f.puts model.work(name_comport, tty, switch) 
      f.close
    end
    loading_time[:all_time]
  end    

  def self.read_status(name_comport)
    file_data = ""
    File.open("log/result.log").each do |line|
      file_data << line  
    end
    file_data.slice(/(?<=#{name_comport}:).*/)
  end

  def self.logging(tty, result, name_comport, model_switch)
    time = Time.now
    time = time.strftime("%Y_%m_%d__%H_%M_%S")
    f = File.new("log/result/#{time}", 'a')
      tty.each_index do |index|
        f.puts "-----------------------------------------------------------"
        f.puts "#{name_comport[index]}(#{model_switch[index]}) - #{result[index]}"
        f.puts "-----------------------------------------------------------"
        File.open("log/#{tty[index]}.log").each { |line| if (/(\||\/|\-|\\)+/ =~ line).nil? then f.puts line end }
      end
    f.close
  end

end
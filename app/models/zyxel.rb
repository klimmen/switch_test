class Zyxel

  def timeout(serial)
    case serial
      when "zyxel2024"  then return {loading_switch:40, download_time_rom:30, download_time_switch:500, all_time:680}
      when "zyxel2108"  then return {loading_switch:40, download_time_rom:20, download_time_switch:730, all_time:830}
      when "zyxel3124"  then return {loading_switch:40, download_time_rom:60, download_time_switch:580, all_time:660}
      when "zyxel3500"  then return {loading_switch:40, download_time_rom:60, download_time_switch:900, all_time:1030}
      when "zyxel35008" then return {loading_switch:40, download_time_rom:60, download_time_switch:580, all_time:660}
      when "zyxel3528"  then return {loading_switch:40, download_time_rom:80, download_time_switch:680, all_time:870}
    end
  end

  def switch_connect?(sp)
    t_start = Time.now
    char = 0
    while char < 15 && (Time.now - t_start < 30) do
  	  sp.read_timeout = 1000
      print sp_char = sp.getc
      if !sp_char.nil?
        char+=1
      end
    end
    return char < 15
  end


  def bad_char?(sp)
    bad_char = 10
    while 0 < bad_char && bad_char < 20 do
  	  sp.read_timeout = 10000
      print sp_char = sp.getc
      !sp_char.nil? && sp_char.valid_encoding? ? bad_char +=1 : bad_char -=1
    end    
    return bad_char.zero?
  end


  def myreadline(sp,str, timeout, f)
    t_start = Time.now
    start = true
    st_string = ''
    while start do 
  	  sp.read_timeout = 1000
      print sp_char = sp.getc
      
      if Time.now - t_start > timeout
        start = false    
        return nil         
      end 
      if !sp_char.nil? && sp_char.valid_encoding? 
        f.write sp_char
        st_string << sp_char.to_s
        if st_string.scan(str).any? 
          start = false
          return true 
        end
      end     
    end
  end


  def work(name_comport, tty, switch)
    File.open("log/#{tty}.log", 'w'){ |file| file.write "" }
    f = File.new("log/#{tty}.log", 'a')
    downtime = timeout(switch)
    sp = SerialPort.new("/dev/tty#{tty}", 9600)
    sp.read_timeout = 0
    f.puts "checking for switch connect"
    ( sp.close; f.close; return "#{name_comport}:no connect ")if switch_connect?(sp)
    f.puts "checking for bad characters"
    if bad_char?(sp)
      sp.baud = 115200
      f.puts "bad_char = true, open /dev/tty#{tty} 115200"
    end
    (sp.close; f.close; return "#{name_comport}:switch другой модели")if myreadline(sp, "seconds", downtime[:loading_switch], f).nil?
    sleep 2
    sp.print("\r") 
    sleep 1
    sp.print("\r")
    sleep 1
    sp.print("\r")
    sleep 1
    if sp.baud == 9600
      sp.print("atba5\r")
      sleep 2
      sp.baud = 115200
      f.puts "open /dev/tty#{tty} 115200"
    end
    sp.print("atlc\r")
    (sp.close; f.close; return "#{name_comport}:не зашло в bootmanager")if myreadline(sp, "CCC",7, f).nil?
    sp.close
    f.puts "start ROM upload"
    sleep 2
    `screen -L -S #{tty} -d -m /dev/tty#{tty} 115200`
    `screen -S #{tty} -X exec \!\! sx  public/rom/#{tty}/#{switch}.rom`
    f.puts "#{switch} download file"
    sleep downtime[:download_time_rom]
    `screen  -S #{tty} -X hardcopy log/screen#{tty}`
    `screen -S #{tty} -X quit`
    file = IO.read("log/screen#{tty}")
    (f.close; return "#{name_comport}:Файл не загружен") if file.slice('OK').nil?
  	f.puts "ROM uploading success"
    sleep 2
	  sp = SerialPort.new("/dev/tty#{tty}", 115200)
    sleep 3
    sp.print("\ratgo\r")
    f.puts "switch reboots"
    sleep 2
    sp.baud = 9600
    f.puts "open /dev/tty#{tty} 9600"
    sleep 2
    if myreadline(sp, "ENTER", downtime[:download_time_switch], f).nil?
      (sp.close; f.close; return "#{name_comport}:rtk_port_loopback_get")if !myreadline(sp, "rtk_port_loopback_get", 5, f).nil?
      (sp.close; f.close; return "#{name_comport}:Tucana MMU DRAM CG0.M1 CRC error at 0x00000000 ")if !myreadline(sp, "Tucana", 5, f).nil?
      (sp.close; f.close; return "#{name_comport}:no data abort occured")if !myreadline(sp, "Data abort occured", 30, f).nil?
      sp.close
      f.close
      return"#{name_comport}:unknown error"
    end
    f.puts ""
    f.puts "switch is up"
    sleep 1
    sp.print("\r")
    sleep 1
    sp.print("admin\r")
    sleep 1
    sp.print("1234\r")
    (sp.close; f.close; return "#{name_comport}:не зашло на свич")if myreadline(sp, "ZyXEL Communications Corp", 5, f).nil?
    sp.read_timeout = 0
    f.puts "OK default"
    f.close
    return "#{name_comport}:OK default"    
  end

end

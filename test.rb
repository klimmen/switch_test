require 'rubygems'
require 'serialport'

def switch_connect?
  t_start = Time.now
  char = 0
  while char < 15 && (Time.now - t_start < 30) do
  	@sp.read_timeout = 1000
    print sp_char = @sp.getc
    if !sp_char.nil?
      char+=1
    end
  end
  return char < 15
end


def bad_char?
  bad_char = 10
  while 0 < bad_char && bad_char < 20 do
  	@sp.read_timeout = 10000
    print sp_char = @sp.getc
    !sp_char.nil? && sp_char.valid_encoding? ? bad_char +=1 : bad_char -=1
  end    
  return bad_char.zero?
end


def myreadline(str, timeout, error)
  t_start = Time.now
  start = true
  st_string = ''
  while start do 
  	@sp.read_timeout = 1000
    print sp_char = @sp.getc
    if Time.now - t_start > timeout
      puts error
      start = false
      @sp.close             
    end 
    if !sp_char.nil? && sp_char.valid_encoding? 
      st_string << sp_char.to_s
      if st_string.scan(str).any? 
        start = false 
      end
    end     
  end
end


def work
  @sp = SerialPort.new("/dev/ttyS4", 9600)
  @sp.read_timeout = 0
  puts "open /dev/ttyS4 9600" 
  
  puts "switch_connect?"
  if switch_connect?
  	puts
    puts "нет подключения"
  else

    puts "bad_char?"
    if bad_char?
      @sp.baud = 115200
      puts
      puts "кракозябрики, переходим на скорость 115200"
    end

    myreadline("Press", 180, "не удалось зайти в bootrom") #-----------------------------------
    puts
    sleep 2
    @sp.print("\r") 
    sleep 1
    @sp.print("\r")
    sleep 1
  
    if @sp.baud == 9600
      @sp.print("atba5\r")
      puts"atba5"
      sleep 2
      @sp.baud = 115200
      puts "open /dev/ttyS4 115200"
    end

    @sp.print("atlc\r")
     myreadline("CCC",5, "не загружается rom") #----------------------------------- 
    puts
    @sp.close
    puts "SerialPort close "
    sleep 2

   `screen -L -S qqq -d -m /dev/ttyS4 115200`
   `screen -S qqq -X exec \!\! sx  zyxel2024.rom `
   puts "Начало загрузки файла"
   sleep 30
   `screen  -S qqq -X hardcopy qqqw`
   `screen -S qqq -X quit`
   file = IO.read('screenlog.0')
   if file[-250..-1].slice('Erasing').nil?
   puts "Файл не загружен"	
   else
   puts "Файл загружен"
   end
   sleep 2

    @sp = SerialPort.new("/dev/ttyS4", 115200)
    puts "open /dev/ttyS4 115200"
    sleep 3
    @sp.print("\ratgo\r")
    puts "atgo"
    puts @sp.baud
    sleep 2
    @sp.baud = 9600
    puts @sp.baud
    sleep 2
  
    myreadline("ENTER", 540, "error") #-----------------------------------
    puts
    sleep 1
    @sp.print("\radmin\r")
    sleep 1
    @sp.print("1234\r")
    myreadline("2024", 5, "не зашло на свич")#-----------------------------------
    puts
    @sp.read_timeout = 0
    @sp.close
    puts "close /dev/ttyS4 9600"
    puts "!!!!!!!!!!!!!!!!!!!!!! GOOD !!!!!!!!!!!!!!!!!!!!!!!!!!"
  end
end

work

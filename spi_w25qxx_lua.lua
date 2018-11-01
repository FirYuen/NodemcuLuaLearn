pin=8
spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8,8);
gpio.mode(pin, gpio.OUTPUT)


function bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return s
end

function tostr(s)
    s=string.gsub(s,"(.)",function (x) return x end)
    return s
end

function writeEnable()
gpio.write(pin, gpio.HIGH)
tmr.delay(30)
gpio.write(pin, gpio.LOW)
spi.send(1,0x06)
gpio.write(pin, gpio.HIGH)
tmr.delay(30)
end

function wd(page,addr,data)
writeEnable()
gpio.write(pin, gpio.LOW)
spi.send(1,0x02)
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 16)), 0xFF))
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 8)), 0xFF))
spi.send(1,string.format("0x%02X",addr))
spi.send(1,data)
gpio.write(pin, gpio.HIGH)
end


function checkbusy()
gpio.write(pin, gpio.HIGH)
tmr.delay(30)
gpio.write(pin, gpio.LOW)
spi.send(1,0x05)
busy = spi.recv(1, 1)
gpio.write(pin, gpio.HIGH)
print(bin2hex(busy))
isbusy:start()
end 

function rd(page,addr,len)
gpio.write(pin, gpio.HIGH)
tmr.delay(30)
gpio.write(pin, gpio.LOW)
tmr.delay(30)
spi.send(1,0x03)
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 16)), 0xFF))
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 8)), 0xFF))
spi.send(1,string.format("0x%02X",addr))
tmr.delay(30)
read = spi.recv(1, len)
gpio.write(pin, gpio.HIGH)
print(bin2hex(read))
print(tostr(read))
end

function erase(page)
writeEnable()
gpio.write(pin, gpio.LOW)
spi.send(1,0x20)
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 16)), 0xFF))
spi.send(1,bit.band(string.format("0x%02X", bit.arshift(page, 8)), 0xFF))
tmr.delay(150)
read = spi.recv(1, 1)
tmr.delay(150)
gpio.write(pin, gpio.HIGH)
print(bin2hex(read))
rd(1024,1,30)
end

--erase(1024)

rd(1024,1,255)

--wd(1026,1,"hello world! i'm here")
rd(1024,1,30)


--This script controls two relais on an ESP8266 running GPIO Univiersal IO Bridge
--This script uses a python script to communicate to the ESP8266

--Watches the following variable for a change
--Value of 0: Ventilation set to lowest
--Value of 1: Ventilatrion set to middle (relias 1 set to on)
--Value of 2: Ventilatrion set to high (relias 2 set to on)
local ventilationVarName = 'Ventilatie'
local espIP = '192.168.1.19'
local relaisOneGPO = 12
local relaisTwoGPO = 13
local espPyPath = "C:\\Program Files (x86)\\Domoticz\\scripts\\lua\\ESPGPIO.py"

function SetRelais(relais, value)
	print("Setting relais " .. relais .. " to: " .. value)
	command = 'python "' .. espPyPath .. '" -s ' .. espIP .. ' -g ' .. relais .. ' -v ' .. value
	local handle = io.popen(command)
	if(handle==nil or handle==0) then
		print('Please specify path of ESPGPIO.py and install python')
	end
	local result = handle:read("*a")
	handle:close()
	
	
	print(result)
end

function SetVentilation(ventilationSetTo)
	print('Setting ventilation to ' .. ventilationSetTo)
	setRelaisOne =0
	setRelaisTwo =0
	if(ventilationSetTo==1) then
		setRelaisOne=1
	elseif(ventilationSetTo==2) then
		setRelaisTwo=1
	end
	SetRelais(relaisOneGPO, setRelaisOne)
	SetRelais(relaisTwoGPO, setRelaisTwo)
end
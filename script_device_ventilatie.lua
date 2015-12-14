--This script reacts on the change of the ventilation buttons
-- and performs the ventilation action and sets the status of the other buttons
require("Ventilatie")
ventilationDevicSetting1 = "Ventilatie stand 1"
ventilationDevicSetting2 = "Ventilatie stand 2"
ventilationDevicSetting3 = "Ventilatie stand 3"

commandArray = {}
if (devicechanged[ventilationDevicSetting1] == 'On') then	
	if(SetVentilation(0)) then
		commandArray[ventilationDevicSetting2]='Off'
		commandArray[ventilationDevicSetting3]='Off'
	else
		commandArray[ventilationDevicSetting1] = "Off"
	end
elseif (devicechanged[ventilationDevicSetting2] == 'On') then		
	if(SetVentilation(1)) then
		commandArray[ventilationDevicSetting1]='Off'
		commandArray[ventilationDevicSetting3]='Off'
	else
		commandArray[ventilationDevicSetting2] = "Off"
	end
elseif (devicechanged[ventilationDevicSetting3] == 'On') then	
	if(SetVentilation(2)) then	
		commandArray[ventilationDevicSetting2]='Off'
		commandArray[ventilationDevicSetting1]='Off'
	else
		commandArray[ventilationDevicSetting3] = "Off"
	end
end
return commandArray




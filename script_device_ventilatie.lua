--This script reacts on the change of the ventilation buttons
-- and performs the ventilation action and sets the status of the other buttons
require("Ventilatie")
ventilationDevicSetting1 = "Ventilatie stand 1"
ventilationDevicSetting2 = "Ventilatie stand 2"
ventilationDevicSetting3 = "Ventilatie stand 3"

commandArray = {}
if (devicechanged[ventilationDevicSetting1] == 'On') then		
	commandArray[ventilationDevicSetting2]='Off'
	commandArray[ventilationDevicSetting3]='Off'
	SetVentilation(0)
elseif (devicechanged[ventilationDevicSetting2] == 'On') then		
	commandArray[ventilationDevicSetting1]='Off'
	commandArray[ventilationDevicSetting3]='Off'
	SetVentilation(1)
elseif (devicechanged[ventilationDevicSetting3] == 'On') then		
	commandArray[ventilationDevicSetting2]='Off'
	commandArray[ventilationDevicSetting1]='Off'
	SetVentilation(2)
end
return commandArray




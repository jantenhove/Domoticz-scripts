--This script checks what setting the ventilation needs to be on
--It checks if someone is at home and not asleep, otherwise it sets the ventilation to minimum
--It checks the temperature of the hot water every minute. If it is above a threshold for a specified time it means the shower is on
--it will turn the ventilation on for x minutes. In the future this will be controlled by humidiy
--If none of the above apply it checks if the woodstove is on. This will also set the ventilation to  minimum
--By setting deviceSetVentilationMasterSwithch to Off, this script does nothing
--By setting deviceSetVentilationOnlyShowerSwitch to "on", only showering will be monitored, no controlling of setting 1 and 2 will be done
commandArray = {}

deviceSomeOneAtHome = "Iemand Thuis"
deviceEveryOneAsleep = "Iedereen slaapt"
deviceHotWaterTemp = "Heet water temperatuur"
deviceVentilationSetting1 = "Ventilatie stand 1"
deviceVentilationSetting2 = "Ventilatie stand 2"
deviceVentilationSetting3 = "Ventilatie stand 3"
deviceSetVentilationMasterSwithch = "Ventilatie master switch"
deviceSetVentilationOnlyShowerSwitch = "Ventilatie alleen douchen"
deviceShoweringOn="Douche aan"
varWoodBurnerOn = "Houtkachel aan"
varHotWaterOnAt = "HotWaterOnAt"
varVentilationOff = "VentilationScriptBypassUntil"

hotWaterHighThreshold=55
isShowerAfterMinutes=5
keepVentilationRunningAfterShower = 30

function GetTotalMinutes(varTime)
	TimeHour, TimeMinutes = varTime:match("([^:]+):([^:]+)")
	return  (TimeHour*60+TimeMinutes)
end

function GetStringTime(timeMinutes)
	return tostring(math.floor((timeMinutes/60))%24) .. ':' .. tostring(timeMinutes % 60)
end

if(otherdevices[deviceSetVentilationMasterSwithch]=="Off" ) then
	return
end
date = os.date("*t")
currentSwitchOffMinutes = GetTotalMinutes(uservariables[varVentilationOff])
currentMinutes =  date.hour *60 + date.min
hotWaterOnAt = GetTotalMinutes(uservariables[varHotWaterOnAt])
currentHotWaterTemp =  tonumber(otherdevices_svalues[deviceHotWaterTemp])
setVent = otherdevices[deviceSetVentilationOnlyShowerSwitch]=="Off" 
showerOn = false
--decide wehter to set to setting one or setting two (setting 3 is controlled by shower)
setVentilationToSettingOne = tonumber(uservariables[varWoodBurnerOn]) ==1 or otherdevices[deviceEveryOneAsleep] == "On" or otherdevices[deviceSomeOneAtHome] == "Off"
--store current value (to check for change)
isVentilationOneRunning = otherdevices[deviceVentilationSetting1] == "On"
--check for a high temperature for x minutes


if(currentHotWaterTemp>hotWaterHighThreshold)  then
	--check if we are lunning long enough by checking our time var
	if(hotWaterOnAt==0) then	--hotwater just on so set it to the current time so we can check how long the shower is running
		hotWaterOnAt = currentMinutes
		commandArray['Variable:'..varHotWaterOnAt] = GetStringTime(hotWaterOnAt)
	elseif(currentMinutes-hotWaterOnAt >= isShowerAfterMinutes) then
		showerOn=true
	elseif(currentMinutes <hotWaterOnAt and currentMinutes +1440 -hotWaterOnAt>isShowerAfterMinutes) then --edge case for midnight
		showerOn=true
	end
elseif(hotWaterOnAt>0) then	
	--reset our hotwater on var so we start counting at zero
	commandArray['Variable:'..varHotWaterOnAt] ="00:00"
end
	
--check if changed and set our device
if(otherdevices[deviceShoweringOn]~= (showerOn == true and "On" or "Off")) then --only set if changed to not trigger multiple triggers
	commandArray[deviceShoweringOn]= (showerOn == true and  "On" or "Off")
	if(showerOn) then
		--shower on for the first time
		print("Showering for " .. isShowerAfterMinutes .. " minutes. Ventilation on")	
		commandArray[deviceVentilationSetting3]="On"
	end
end

--if shower is on set our offtime to now + 30 minutes. (TODO: based on humidity)
if(showerOn) then
	currentSwitchOffMinutes=currentMinutes+keepVentilationRunningAfterShower
	commandArray['Variable:'..varVentilationOff] = GetStringTime(currentSwitchOffMinutes) 
else
	--check if we need to switch the  ventilation off
	if(currentSwitchOffMinutes>0) then
		if(currentSwitchOffMinutes==currentMinutes) then
			print("Turning ventilation off " .. keepVentilationRunningAfterShower .. " minutes after showering")
			commandArray['Variable:'..varVentilationOff] = tostring("00:00")
			setVent=true
		else
			setVent=false
		end
	end
	
	if(setVent) then
		--which one, and is it changed
		if(setVentilationToSettingOne and not isVentilationOneRunning ) then
			print("Ventilation 1 needs to be switched on")	
			commandArray[deviceVentilationSetting1]="On"
		elseif(not setVentilationToSettingOne and isVentilationOneRunning) then
			print("Ventilation 2 needs to be switched on")
			commandArray[deviceVentilationSetting2]="On"
		end
	end
end

--Set the previous values for the next iteration
return commandArray
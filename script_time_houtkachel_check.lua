-- demo time script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
-- 
-- copy this script and change the "name" part, all scripts named "demo" are ignored. 
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: otherdevices,otherdevices_svalues
-- 
-- otherdevices and otherdevices_svalues are two item array for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for a state.
-- If you would only specify commandArray['AnotherDevice']='On', every time trigger (e.g. every minute) will switch AnotherDevice on.
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
houtkachelVar = 'Houtkachel aan'
tempTreshold = 10
tempHoutKachel =  tonumber(otherdevices_svalues['Temperatuur houtkachel']:match("([^;]+);"))
tempThermostat =  tonumber(otherdevices_svalues['Kamertemperatuur (thermostaat)'])
tempDifference = tempHoutKachel - tempThermostat

commandArray = {}
if (tempDifference>tempTreshold )  then
	if(tonumber(uservariables[houtkachelVar]) ~= 1) then
		commandArray['Variable:'..houtkachelVar] = tostring(1)
	end
else
	if(tonumber(uservariables[houtkachelVar]) ~= 0) then
		commandArray['Variable:'..houtkachelVar] = tostring(0)
	end
end 

return commandArray
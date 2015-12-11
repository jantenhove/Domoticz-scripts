-- demo device script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
-- 
-- copy this script and change the "name" part, all scripts named "demo" are ignored. 
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: devicechanged, otherdevices,otherdevices_svalues
--
-- device changed contains state and svalues for the device that changed.
--   devicechanged['yourdevicename']=state 
--   devicechanged['svalues']=svalues string 
--
-- otherdevices and otherdevices_svalues are arrays for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for the state of the changed device.
-- If you would only specify commandArray['AnotherDevice']='On', every device trigger will switch AnotherDevice on, which will trigger a device event, which will switch AnotherDevice on, etc. 
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--
-- TBD: nice time example, for instance get temp from svalue string, if time is past 22.00 and before 00:00 and temp is bloody hot turn on fan. 

-- Split text into a list consisting of the strings in text,
-- separated by strings matching delimiter (which may be a pattern). 
-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")

ThermostatOnMinutesBeforeAlarm = 30 
function GetTotalMinutes(varTime)
	TimeHour, TimeMinutes = varTime:match("([^:]+):([^:]+)")
	return  (TimeHour*60+TimeMinutes)
end

commandArray = {}

--commandArray['Plafondlamp']='On'
date = os.date("*t")
if(date.hour==0) and (date.min==0) then
-- Reset the vars
	commandArray['Variable:Alarm Jan']="00:00"
	commandArray['Variable:Alarm Manon']="00:00"
	commandArray['Variable:Thermostaat aan']="00:00"
	print("Midnight var reset")
	return commandArray
end


AlarmJanTotal = GetTotalMinutes(uservariables['Alarm Jan'])
AlarmManonTotal =GetTotalMinutes(uservariables['Alarm Manon'])
ThermostatSetTotal = GetTotalMinutes(uservariables['Thermostaat aan'])
CurTimeTotal = date.hour *60 + date.min

if((AlarmJanTotal >0) and ((AlarmJanTotal -ThermostatOnMinutesBeforeAlarm < ThermostatSetTotal)or (ThermostatSetTotal==0))) then
	 print("Set to time Jan minus start")
	 ThermostatSet = AlarmJanTotal-ThermostatOnMinutesBeforeAlarm
	 commandArray['Variable:Thermostaat aan'] = tostring(math.floor(ThermostatSet/60)) .. ':' .. tostring(ThermostatSet % 60)
elseif((AlarmManonTotal >0) and ((AlarmManonTotal- ThermostatOnMinutesBeforeAlarm< ThermostatSetTotal) or (ThermostatSetTotal==0))) then
	print("Set to time Manon minus start")
	 ThermostatSet = AlarmManonTotal-ThermostatOnMinutesBeforeAlarm
	 commandArray['Variable:Thermostaat aan'] = tostring(math.floor(ThermostatSet/60)) .. ':' .. tostring(ThermostatSet % 60)
end 

--check if we need to set the trigger for heating
if((ThermostatSetTotal>0) and (CurTimeTotal==ThermostatSetTotal)) then
	print("Thermostaat aanzetten")	
	  commandArray['SendNotification']='Thermostaat aan#Verwarming aan, een half uur voor de eerste wekker!'
	  commandArray['Variable:Zet thermostaat aan'] = tostring(1)
end
return commandArray

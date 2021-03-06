$vcenterservers = "vcenter1","vcenter2"
$vcenterusername = 'administrator@vsphere.local'
$vcenteruserpwd = 'password'
#Specify Alarms for vSphere version below, 5.5, 6.0, 6.5
#$alarmfile = import-csv c:\temp\vsphere65-alarms.csv
$AlertEmailRecipients = @("email@domain.com")
$SMTPServer = "smtp.domain.com"
$SMTPPort = "25"
$SMTPSendingAddress = "email@domain.com"

#Import PowerCLI module
import-module -name VMware.PowerCLI

#----These Alarms will be disabled and not send any email messages at all ----
$DisabledAlarms = $alarmfile | where-object priority -EQ "Disabled"

#----These Alarms will send a single email message and not repeat ----
$LowPriorityAlarms = $alarmfile | where-object priority -EQ "low"

#----These Alarms will repeat every 24 hours----
$MediumPriorityAlarms = $alarmfile | where-object priority -EQ "medium"

#----These Alarms will repeat every 4 hours----
$HighPriorityAlarms = $alarmfile | where-object priority -EQ "high"

foreach ($vcenterserver in $vcenterservers){
    Disconnect-VIServer -Confirm:$False
    Connect-VIserver $vcenterserver -User $vcenterusername -Password $vcenteruserpwd
    Get-AdvancedSetting -Entity $vcenterserver -Name mail.smtp.server | Set-AdvancedSetting -Value $SMTPServer -Confirm:$false
    Get-AdvancedSetting -Entity $vcenterserver -Name mail.smtp.port | Set-AdvancedSetting -Value $SMTPPort -Confirm:$false
    Get-AdvancedSetting -Entity $vcenterserver -Name mail.sender | Set-AdvancedSetting -Value $SMTPSendingAddress -Confirm:$false
    
    #---Disable Alarm Action for Disabled Alarms---
    Foreach ($DisabledAlarm in $DisabledAlarms) {
        Get-AlarmDefinition -Name $DisabledAlarm.name | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
        }

    #---Set Alarm Action for Low Priority Alarms---
    Foreach ($LowPriorityAlarm in $LowPriorityAlarms) {
        Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
        Get-AlarmDefinition -Name $LowPriorityAlarm.name | New-AlarmAction -Email -To @($AlertEmailRecipients)
        Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
        #Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red"  # This ActionTrigger is enabled by default.
        Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
        Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
        #Get-AlarmDefinition -Name $LowPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Green" 
    }

    #---Set Alarm Action for Medium Priority Alarms---
    Foreach ($MediumPriorityAlarm in $MediumPriorityAlarms) {
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Set-AlarmDefinition -ActionRepeatMinutes (45 * 1)  # 45 minutes
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | New-AlarmAction -Email -To @($AlertEmailRecipients)
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow" 
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | Get-AlarmActionTrigger | Select -First 1 | Remove-AlarmActionTrigger -Confirm:$false
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat 
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow" 
        Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
        #Get-AlarmDefinition -Name $MediumPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Green" 
    }

    #---Set Alarm Action for High Priority Alarms---
    Foreach ($HighPriorityAlarm in $HighPriorityAlarms) {
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction   -Confirm:$false
        Get-AlarmDefinition -name $HighPriorityAlarm.name | Set-AlarmDefinition -ActionRepeatMinutes (15 * 1)  # 15 minutes 
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | New-AlarmAction -Email -To @($AlertEmailRecipients)  
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"  
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | Get-AlarmActionTrigger | Select -First 1 | Remove-AlarmActionTrigger   -Confirm:$false
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat  
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"  
        Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
        #Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Green"  
    }
}


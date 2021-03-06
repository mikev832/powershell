Import-Module activedirectory

[String]$LogPath="C:\log"
$date = Get-Date 
$datePlusFive=$date.adddays(30).toFileTime()
$dateNow = $date.ToFileTime()  
$now=$date.adddays(30).ToShortDateString()
$recipients = @("Firstname <emailaddress>", "Firstname <email address>")
$bodyMessage="Please find attached this weeks Accounts Expiring Report. Users appear in this report because they have an Account Expiration date. Contractors and employees without an Account Expiration date will not be listed. Thank you."
$recipients = @("name <emailaddress>","name <emailaddress>")


$adUserInformations=@()

if(-not ( Test-Path -Path $LogPath))
	{
		New-Item -ItemType  directory -Path $LogPath 
	}	
    
$adUsers = get-aduser -Filter * -Properties manager,accountexpirationdate, Enabled, department,departmentNumber,displayName,mail,distinguishedName, GivenName,sn,title -ResultSetSize $null -SearchBase "DC=domainname,DC=com" 
$adusers = $adusers | Sort-Object accountexpirationdate

foreach	($adUser in $adUsers)
{
if ($adUser.AccountExpirationDate -ne $null -and $aduser.Enabled -ne $false){

	$dateUserExpires=$aduser.AccountExpirationDate.toFileTime()	

}

 if($dateuserExpires -ge $datenow -and $dateuserExpires -le $datePlusFive ){
			
		$ou=$adUser.distinguishedName
		$ou=$ou.trimEnd(",DC=domainname,DC=com")
		$pos=$ou.indexOf(",")
		$ouTrimmed=$ou.Substring($pos)
		$ouTrimmedFinal=$ouTrimmed.Replace(",OU=","\")	
		
		$us=" "
		
		if ( $adUser.Manager -ne $null ){
			$us=$adUser.manager
			$us=$us.split("=")
			$us=$us[1]
			$us=$us.split(",")
		}
		
			$adUserInformation = New-Object PSObject
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "First Name" -Value $adUser.GivenName
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "Last Name" -Value $adUser.sn
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "Display Name" -Value $adUser.displayName
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "Title" -Value $adUser.Title
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "Manager" -Value $us[0]
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "Account Enabled" -Value $adUser.Enabled
	 		$adUserInformation | Add-Member -MemberType NoteProperty -Name "Account Expiration Date" -Value $adUser.accountexpirationdate
			$adUserInformation | Add-Member -MemberType NoteProperty -Name "OU" -Value $ouTrimmedFinal

			$adUserInformations+=$adUserInformation
	
		} else{}
}
	
	$attName="$LogPath\AccountsExpiringReport.$(get-date -Format "yyyyMMddHHmmss").csv"	
	$adUserInformations|Export-Csv -Encoding default -NoTypeInformation -Path $attName
	$sub="Account Expirations for the 30 days ending "+$now
	Send-MailMessage -smtpServer emailserver -from 'sysadminemailaddress' -to $recipients -Body $bodyMessage -subject $sub  -Attachments $attName
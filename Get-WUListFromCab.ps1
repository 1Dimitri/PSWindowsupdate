Function Get-WUListFromCab
{
	<#
	.SYNOPSIS
	    Get list of available updates meeting the criteria in the wsusscn2.cab file.

	.DESCRIPTION
	    Use Get-WUListFromCab to get list of available or installed updates based on the detection logic found in a wsusscn2.cab offline file
		You can use parameters supported by Get-WUList except for those specifying the Service to use (ServiceID, WindowsUpdate, MicrosoftUpdate)
		
	
	.PARAMETER ServiceID
		Set ServiceIS to change the default source of Windows Updates. It overwrite ServerSelection parameter value.

	.PARAMETER WindowsUpdate
		Set Windows Update Server as source. Default update config are taken from computer policy.
		
	.PARAMETER MicrosoftUpdate
		Set Microsoft Update Server as source. Default update config are taken from computer policy.


	.EXAMPLE
		Get list of available updates from Microsoft Update Server.
	
		PS C:\> Start-BitsTransfer -Source "http://go.microsoft.com/fwlink/?linkid=74689" -Destination C:\temp\wsusscn2.cab
		PS C:\> Set-ItemProperty -Path c:\temp\wsusscn2.cab -Name IsReadOnly -Value $False
		PS C:\> Get-WUListFromCab -CabPath C:\temp\wsusscn2.cab

		ComputerName KB        Size   Status Title
		----------- --        ----   ------ -----
		FOOBAR	    KB3013769 56 MB  ------ Update for Windows Server 2012 R2 (KB3013769)
		FOOBAR	    KB3084905 2 MB   ------ Update for Windows Server 2012 R2 (KB3084905)
		FOOBAR	    KB3102429 21 MB  ------ Update for Windows Server 2012 R2 (KB3102429)
		FOOBAR	    KB4034663 271 MB ------ 2017-08 Preview of Monthly Quality Rollup for Windows Server 2012 R2 for x64
		FOOBAR	    KB4035038 73 MB  ------ August, 2017 Preview of Quality Rollup for .NET Framework 3.5, 4.5.2, 4.6

		
	.NOTES
		Author: Dimitri Janczak
		Blog  : https://dimitri.janczak.net
		
	.LINK
		Get-WUList
		
	#>

	[OutputType('PSWindowsUpdate.WUList')]
	[CmdletBinding(
		SupportsShouldProcess=$True,
		ConfirmImpact="High"
	)]	
	Param
	(

		[parameter(mandatory=$true, position=0)][System.IO.FileInfo]$FromCab,
		[parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$Remaining
	)

	
		'ServiceID','MicrosoftUpdate','WindowsUpdate' | Foreach-Object {
			if ($PSBoundParameters.ContainsKey($_)) {
			throw "You cannot use parameter $_ with this cmdlet"
			}
		}
		$Name = "WSUSScan$(Get-Random)"
		Write-Verbose "Registering offline file $FromCab under Name $Name"
		$TempService = Add-WUOfflineSync -Path $FromCab -Name $Name
		if ($TempService) {
			Write-Verbose "Using Service ID $($TempService.ServiceId)"
			if ($Remaining.Count -eq 0) {
					Get-WUList -ServiceID $TempService
				}
			else {
					Get-WUList -ServiceID $TempService @Remaining
				}	
			Write-Verbose "Removing entry $Name"	
			Remove-WUServiceManager -ServiceID $TempService.serviceID
			}
	

	
} #EOF
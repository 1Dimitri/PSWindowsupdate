Function Get-WUList
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
	
		PS C:\> Get-WUListFromCab -CabPath C:\temp\wsusscn2.cab

		ComputerName Status KB          Size Title
		------------ ------ --          ---- -----
		KOMPUTER     ------ KB976002  102 KB Aktualizacja firmy Microsoft z ekranem wybierania przeglądarki dla użytkowników...
		KOMPUTER     ------ KB971033    1 MB Aktualizacja dla systemu Windows 7 dla systemów opartych na procesorach x64 (KB...
		KOMPUTER     ------ KB2533552   9 MB Aktualizacja systemu Windows 7 dla komputerów z procesorami x64 (KB2533552)
		KOMPUTER     ------ KB982861   37 MB Windows Internet Explorer 9 dla systemu Windows 7 - wersja dla systemów opartyc...
		KOMPUTER     D----- KB982670   48 MB Program Microsoft .NET Framework 4 Client Profile w systemie Windows 7 dla syst...
		KOMPUTER     ---H-- KB890830    1 MB Narzędzie Windows do usuwania złośliwego oprogramowania dla komputerów z proces...

		
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

		[parameter(mandatory=$true, position=0)][string]$FromCab
		[parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$Remaining
	)

	{
		'ServiceID','MicrosoftUpdate','WindowsUpdate' | Foreach-Object {
		  if ($PSBoundParameters.ContainsKey($_))
			throw "You cannot use parameter $_ with this cmdlet"
		}
		$TempService = Add-WUOfflineSync -Path $FromCab		
		if ($TempService) {
			Get-WUList -ServiceID $TempService @Remaining		
			Remove-WUOfflineSync $TempService
			}
	}

	
} #EOF
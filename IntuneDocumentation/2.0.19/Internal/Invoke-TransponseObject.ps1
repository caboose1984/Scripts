function Invoke-TransposeObject { 
	<#
	.SYNOPSIS
	Transpose properties of objects from columns to rows.
	.DESCRIPTION
	Transpose properties of objects from columns to rows. Useful when the order displayed in a GridView (with
	Out-GridView) or in a CSV file (with Export-Csv) should be rotated.
	It uses the name property as new property names (column headers) if it exists.
	.INPUTS
	Object
	.OUTPUTS
	Transposed object
	.EXAMPLE
	dir | Transpose-Object | Out-GridView

	Shows directory listing with a column instead of a row for every file/directory
	.EXAMPLE
	ps | Transpose-Object | Export-Csv Processes.csv -Delimiter ';' -NoTypeInformation

	Creates a CSV file with a column instead of a row for every process
	.NOTES
	Name: Transpose-Object
	Author: Markus Scholtes
	Version: 1.0 - Initial version
	Creation Date: 01/11/2019
	#>
	[OutputType('System.Object[]')]
	[CmdletBinding()]
	Param([OBJECT][Parameter(ValueFromPipeline = $TRUE)]$InputObject)

	BEGIN
	{ # initialize variables just to be "clean"
		$Props = @()
		$PropNames = @()
		$InstanceNames = @()
	}

	PROCESS
	{
		if ($Props.Length -eq 0)
		{ # when first object in pipeline arrives retrieve its property names
				$PropNames = $InputObject.PSObject.Properties | Select-Object -ExpandProperty Name
				# and create a PSCustomobject in an array for each property
				$InputObject.PSObject.Properties | ForEach-Object{ $Props += New-Object -TypeName PSObject -Property @{Property = $_.Name} }
			}

			if ($InputObject.M_DisplayName)
			{ # does object have a "Name" property?
				$Property = $InputObject.M_DisplayName
			} else { # no, take object itself as property name
				$Property = $InputObject | Out-String
			}

			if ($InstanceNames -contains $Property)
			{ # does multiple occurence of name exist?
			$COUNTER = 0
				do { # yes, append a number in brackets to name
					$COUNTER++
					$Property = "$($InputObject.M_DisplayName) ({0})" -f $COUNTER
				} while ($InstanceNames -contains $Property)
			}
			# add current name to name list for next name check
			$InstanceNames += $Property

		# retrieve property values and add them to the property's PSCustomobject
		$COUNTER = 0
		$PropNames | ForEach-Object{
			if ($InputObject.($_))
			{ # property exists for current object
				$Props[$COUNTER] | Add-Member -Name $Property -Type NoteProperty -Value $InputObject.($_)
			} else { # property does not exist for current object, add $NULL value
				$Props[$COUNTER] | Add-Member -Name $Property -Type NoteProperty -Value $NULL
			}
				$COUNTER++
		}
	}

	END
	{
		# return collection of PSCustomobjects with property values
		$Props
	}
}
# SIG # Begin signature block
# MIIPGgYJKoZIhvcNAQcCoIIPCzCCDwcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJbQPePFBebDdB9OjappI+m58
# zqygggxqMIIFrTCCBJWgAwIBAgIQBD9LZ/ZeEn/YHaINoG/0ljANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBFViBDb2Rl
# IFNpZ25pbmcgQ0EwHhcNMjAwMzA2MDAwMDAwWhcNMjMwMzE1MTIwMDAwWjCBzjET
# MBEGCysGAQQBgjc8AgEDEwJDSDEaMBgGCysGAQQBgjc8AgECEwlTb2xvdGh1cm4x
# HTAbBgNVBA8MFFByaXZhdGUgT3JnYW5pemF0aW9uMRgwFgYDVQQFEw9DSEUtMzE0
# LjYzOS41MjMxCzAJBgNVBAYTAkNIMRIwEAYDVQQIEwlTb2xvdGh1cm4xETAPBgNV
# BAcMCETDpG5pa2VuMRYwFAYDVQQKEw1iYXNlVklTSU9OIEFHMRYwFAYDVQQDEw1i
# YXNlVklTSU9OIEFHMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp9MW
# Qk/Mk+vNR2VWPILVJVESssMvDX6vLor/4ySVPv03+Bx11ycx6PemRaP1jljA91jF
# kWEZ6Y/eT2W3y2hfpIvz1EUYaff6E/6eTt807+Cap4oOwDniC+XbfVuVIo/awzhG
# YZhaVU9PCgioTDTDLuzIQbPrhwZckO9I+R9iIwY3j7RA2HGpG79UTQyuYVPpNlKi
# mREEmqrdvq4nsMUtkeEVL2SeZ0a2n+KTWKg3Xpth9Lyde8x7BvmQdGBS5Pz94uq+
# LSRAJLGAFJLibBQ7dGM/cTNqphtka+IsOwFE3xORsdDTVg/3zFhT/9rA91ZBwPDM
# /DwKJA3xc9tTqmK1zwIDAQABo4IB7TCCAekwHwYDVR0jBBgwFoAUrWkGcPyAGxaz
# qRiUa5QChl73J4wwHQYDVR0OBBYEFEXZZP9kZKig72bPLKJdFIc5iUwqMDcGA1Ud
# EQQwMC6gLAYIKwYBBQUHCAOgIDAeDBxDSC1TT0xPVEhVUk4tQ0hFLTMxNC42Mzku
# NTIzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzBzBgNVHR8E
# bDBqMDOgMaAvhi1odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRVZDb2RlU2lnbmlu
# Zy1nMS5jcmwwM6AxoC+GLWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9FVkNvZGVT
# aWduaW5nLWcxLmNybDBLBgNVHSAERDBCMDcGCWCGSAGG/WwDAjAqMCgGCCsGAQUF
# BwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAcGBWeBDAEDMHkGCCsG
# AQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRFVkNvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEF
# BQADggEBABmHqy/WAPIFuHMe51hGgxaTdl52mOPvdDZfIGo+mnkI+pMCH41i1gMw
# cg3VTb8UpK8F3X6N3ZBuQzTSN8D0dkhNosiJgxes1004XHAapMBNcdU2+an4WgOP
# I39fH/CW71YL7W2Vl6YdW/gC8g9vddW9+ELenGJqJYNfb5Jll2VAA0YwNdUt1R4Y
# R+Biynh6BNt40krOvbUDzQtY3Uvkcesjv2GteFKw8DqyaNakp9sU4pX/bO+5ksUS
# QqS/AndT1Bz77oFBRy8PZ6jkADFG+3B3Q1ERLOwa733MqNKkce5cioyDNXdMBrYg
# c/vJECXEgnSvUvBxkg98uEdTfvmPIGEwgga1MIIFnaADAgECAhAN0OM3Sslb2/pr
# Q0sqSOwGMA0GCSqGSIb3DQEBBQUAMGwxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xKzApBgNVBAMT
# IkRpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIEVWIFJvb3QgQ0EwHhcNMTIwNDE4MTIw
# MDAwWhcNMjcwNDE4MTIwMDAwWjBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtE
# aWdpQ2VydCBFViBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC5BnQcXbQgqqkhqCpCRqslIBclyyKPkKKgMWuDBXWvsg58Ekl7
# aoZkhA+D3GS5sW4WBT4clbnn54htuGKBkHnU3fXilvnDtYgjV0oaz3Ep6QgAj7WY
# 46cy/awuuPSTU/QKOUORr9Vr6NSfRr2OPavi+SvU6gBAZiS36H+0RHWNeJquMcE3
# z04fW/hFStc/wsmSBmS+3gaKr9DoirHwLIgAbwvchadMywa/1i4qMm4pca+OIvMP
# 0NiYSC2oCMu2iyPCY+C2c+tvfSZPi/c0PTeGDLd4J/TChttDa1r4PT306LBiVsbn
# 7Xih+/16ck8yZcR8w8R3oAQyMu2PP6+G3X7RAgMBAAGjggNYMIIDVDASBgNVHRMB
# Af8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcD
# AzB/BggrBgEFBQcBAQRzMHEwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBJBggrBgEFBQcwAoY9aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0SGlnaEFzc3VyYW5jZUVWUm9vdENBLmNydDCBjwYDVR0fBIGHMIGE
# MECgPqA8hjpodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRIaWdoQXNz
# dXJhbmNlRVZSb290Q0EuY3JsMECgPqA8hjpodHRwOi8vY3JsNC5kaWdpY2VydC5j
# b20vRGlnaUNlcnRIaWdoQXNzdXJhbmNlRVZSb290Q0EuY3JsMIIBxAYDVR0gBIIB
# uzCCAbcwggGzBglghkgBhv1sAwIwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUH
# AgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQBy
# AHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBj
# AGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAg
# AEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQ
# AGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBt
# AGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBj
# AG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBl
# AHIAZQBuAGMAZQAuMB0GA1UdDgQWBBStaQZw/IAbFrOpGJRrlAKGXvcnjDAfBgNV
# HSMEGDAWgBSxPsNpA/i/RwHUmCYaCALvY2QrwzANBgkqhkiG9w0BAQUFAAOCAQEA
# nluWOi4SiKyrAW2kn3XkAYejpTLXvLqpfqPWFBf3whNrfHOPK2rlDyZZaLCOJZts
# 7/psk5IIwU3PRZ6cRtYedKGbFKP6AS9KsQHhckBIERNouTadkUvXwjkSEMHE3Lti
# FBQqYV1POHxmH8Yb/62+T3+UW3NDAA9Nc7dRzw72d8BbzTSM2WMTqg5hEdbyjif8
# tHu4uREgkYZ46g7UKP8q1SQ46Dey7Ja7n7xKFlDhXr9RfSOgMsfBlJ56ycAmoswl
# h6ASfnSfLY2xyOeEvrnR6d67ak6Ic3HhIjjLJIfpc35Rsv+Y605+L+DKDvqzXtG6
# BUKoSJ+D9j/EyqjfaKBQYTGCAhowggIWAgEBMHkwZTELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEk
# MCIGA1UEAxMbRGlnaUNlcnQgRVYgQ29kZSBTaWduaW5nIENBAhAEP0tn9l4Sf9gd
# og2gb/SWMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQeL086MdPKntsoVy2OTya09lfQXTANBgkq
# hkiG9w0BAQEFAASCAQCGGfuDj5IDA1MCOylxAQ3M9PjaGgCmsxsJKCHbmbHzCLj/
# 2WdCAdVunGvWq7cTREOfb23BPBZBKxcRhESJhL4u0+SPRlQHPPVJDSH8u31RvX3c
# +zxdjUVHCwrAbmngKrps/dmxG4LKYHyMaPk/dTe5ts+xwxWm7To4RQvAPmi+C0gz
# sOwqVSUOSAzATK+tlT9IHaGwFnVtsV+XfVnV/yi5Hs2FjcSjFTI/ZLCYnu6jiqVn
# GeFnJ+UDciNoXfuyZxRIVtbpclwj7XVbv0xZWTmP3Jwkx/h9dR7eR2SDBseUGkpy
# +qMs5tBbjzxkyPXZSsjNgBqYs7rsfdaBeMrm/Ruy
# SIG # End signature block

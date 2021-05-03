#function adpr() to add printer
Function adpr {
add-printer -ConnectionName $args[0]}

#Function dpr() to Set default printer
Function dpr {
$apn =$args[0]
$a = Get-WMIObject -query "Select * From Win32_Printer Where ShareName = '$apn'"
$a.SetDefaultPrinter()
}

$cn = $env:COMPUTERNAME

Switch -Wildcard ($cn)
{
    "ST???227*" {  
                #\\server and sharename of the printer
                adpr "\\nsccsaps2\SA 227 Laser"
                adpr "\\nsccsaps2\SA 227 Color"
                #Set default printer
                dpr "SA 227 Laser"
                }

    "ST???312*" { 
                adpr "\\nsccsaps2\SA 312 Laser"
                dpr "SA 312 Laser"
                }

    "ST???313*" {
                adpr "\\nsccsaps2\SA 313 Laser"
                dpr "SA 313 Laser"
                }

    "ST???314*" {  
                adpr "\\nsccsaps2\SA 314 Laser"
                dpr "SA 314 Laser"
                }

    "ST???187*" {  
                adpr "\\nsccsaps2\SA 187 Color Laser"
                adpr "\\nsccsaps2\SA 187 Copier"
                dpr "SA 187 Copier"
                }

                #Put something here for Admin machines in library
   "ST???187CIRC*" {
                adpr "\\nsccsaps2\SA 187 Color Laser"
                adpr "\\nsccsaps2\SA 187 Copier".
                adpr "\\nsccsaps2\SA 187 Staff Laser"
                dpr "SA 187 Staff Laser"
                }

    "ST???141*" {  
                adpr "\\nsccsaps2\SA 141 Laser"
                dpr "SA 141 Laser"
                }

    "ST???213*" { 
                adpr "\\nsccsaps2\SA 214 Laser"
                adpr "\\nsccsaps2\SA 224 Copier"
                dpr "SA 214 Laser"
                }

    "ST???214*" { 
                adpr "\\nsccsaps2\SA 214 Laser"
                dpr "SA 214 Laser"
                }

    "ST???211*" {  
                adpr "\\nsccsaps2\SA 214 Laser"
                dpr "SA 214 Laser"
                }

    "ST???322*" { 
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???224*" {
                adpr "\\nsccsaps2\SA 224 Copier"
                dpr "SA 224 Copier"
                }

    "ST???209*" {
                adpr "\\nsccsaps2\SA 224 Copier"
                dpr "SA 224 Copier"
                }

    "ST???222*" {
                adpr "\\nsccsaps2\SA 224 Copier"
                dpr "SA 224 Copier"
                }

    "ST???270*" { 
                adpr "\\nsccsaps2\SA 248 Laser"
                dpr "SA 248 Laser"
                }

    "ST???248*" { 
                adpr "\\nsccsaps2\SA 248 Laser"
                dpr "SA 248 Laser"
                }

    "ST???288*" {
                adpr "\\nsccsaps2\SA 241 Copier"
                dpr "SA 241 Copier"
                }

    "ST???350*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???344*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???343*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???317*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???221*" {
                adpr "\\nsccsaps2\SA 241 Copier"
                dpr "SA 241 Copier"
                }

    "ST???242*" {
                adpr "\\nsccsaps2\SA 241 Copier"
                dpr "SA 241 Copier"
                }

    "ST???241*" {
                adpr "\\nsccsaps2\SA 241 Copier"
                dpr "SA 241 Copier"
                }

    "ST???216*" {  
                adpr "\\nsccsaps2\SA 216 Laser"
                dpr "SA 216 Laser"
                }

    "ST???217*" {  
                adpr "\\nsccsaps2\SA 216 Laser"
                dpr "SA 216 Laser"
                }

    "ST???348*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???321*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                dpr "SA 340 Copier"
                }

    "ST???172*" {  
                adpr "\\nsccsaps2\SA 172 Copier"
                dpr "SA 172 Copier"
                }

    "ST???500*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }

    "ST???502*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }

    "ST???503*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }
               
    "ST???504*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }

    "ST???505*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }

    "ST???506*" {  
                adpr "\\nsccsaps2\SA FireSchool Laser"
                dpr "SA FireSchool Laser"
                }

    "ST???342*" {  
                adpr "\\nsccsaps2\SA 340 Copier"
                adpr "\\nsccsaps2\SA 342 la"
                dpr "SA 342 la"
                }

    "ST???369*" {  
                adpr "\\nsccsaps2\SA 369 Copier"
                dpr "SA 369 Copier"
                }

    "ST???164*" {  
                adpr "\\nsccsaps2\SA 164 Copier"
                adpr "\\nsccsaps2\Sa 164 Laser"
                dpr "SA 164 Copier"
                }

    "SW???125*" {  
                adpr "\\nsccsaps2\WA 125 Color"
                dpr "WA 125 Color"
                }

    "SW???104*" {  
                adpr "\\nsccsaps2\WA Copier"
                dpr "WA Copier"
                }

    "SW???106*" {  
                adpr "\\nsccsaps2\WA Copier"
                dpr "WA Copier"
                }

    "SW???139*" {  
                adpr "\\nsccsaps2\WA Copier"
                dpr "WA Copier"
                }

    "SW???110*" {  
                adpr "\\nsccsaps2\WA Copier"
                dpr "WA Copier"
                }

    "SW???128*" {  
                adpr "\\nsccsaps2\WA Copier"
                dpr "WA Copier"
                }

    "SW???102*" {  
                adpr "\\nsccsaps2\WA 102 Laser"
                dpr "WA 102 Laser"
                }

    "SW???103*" {  
                adpr "\\nsccsaps2\WA 102 Laser"
                dpr "WA 102 Laser"
                }
}
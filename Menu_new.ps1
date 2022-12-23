$FilePath = "C:\Users\ioserafimov\Downloads\Scripts\Folder.xml"

$MenuFile = [xml](Get-Content $FilePath)

$ElementList = New-Object System.Collections.Generic.List[System.Object]


$MenuLevel0 = $MenuFile | Select-Object -ExpandProperty Folders | Select-Object -ExpandProperty SubFolders | Select-Object -ExpandProperty Folder


function MenuElement {
   
    param (
        [string]$PathName,
        [string]$Order,
        [string]$Url,
        [string]$UrlType
    )

    $MenuStructure = @("Name", "MainMenuItem", "NavigationMenuItem", "Order", "Type", "Url") 

    foreach ($MenuItem in $MenuStructure) { 

        if ($MenuItem -eq "Name") {
            
            $Object = New-Object PSObject -Property @{
            Type = "Element"
            Path = "\\I-DS/RO\MainMenu\Ванкорское месторождение\$PathName"
            Name = $PathName.Split("\")[-1]
            ElementTemplate = "I-DS/RO.MainMenuItem"
            AttributeDataReference = ""
            AttributeDataReferenceProperties = ""
            AttributeValueType = ""
            AttributeUOM = ""
            AttributeDisplayDigits = ""
            }            
            $ElementList.Add($Object)
        }

        if ($MenuItem -eq "MainMenuItem" -or $MenuItem -eq "NavigationMenuItem" -or $MenuItem -eq "Order" -or $MenuItem -eq "Type" -or $MenuItem -eq "Url") {
            
            switch ($MenuItem) {
                "MainMenuItem" {$Value = 'False'; $ValueType = '3'}
                "NavigationMenuItem" {$Value = 'True'; $ValueType = '3'}
                "Order" {$Value = $Order; $ValueType = '11'}
                "Type" {$Value = $UrlType; $ValueType = '11'}
                "Url" {$Value = "$($Url -replace '/', '\')"; $ValueType = '18'} #убрать Vankor\ из меременной, так как пихает это значение там где поле должно быть пустое 
            }
            
            $Object = New-Object PSObject -Property @{
            Type = "Attribute"
            Path = "\\I-DS/RO\MainMenu\Ванкорское месторождение\$PathName\$MenuItem"
            Name = $MenuItem
            ElementTemplate = ""
            AttributeDataReference = "Static"
            AttributeDataReferenceProperties = "Value=$Value↔ViolatesNoFutureAccessRule=False↔NoArchive=False"
            AttributeValueType = $ValueType
            AttributeUOM = "\\Системные\Отсутствует"
            AttributeDisplayDigits = "0"
            }            
            $ElementList.Add($Object)
        }

    }
} #end of function MenuElement



foreach ($MenuLevel1 in $MenuLevel0) {     
    #Write-Host "\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)" -ForegroundColor Green
    $PathName = $MenuLevel1.Name
    $Order = $MenuLevel1.Order
    $Url = ""
    $UrlType = ""
    MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType  

    #Перечисляем подпапки lvl1
    if ($MenuLevel1.SubFolders -ne "") {
        foreach ($MenuLevel2 in ($MenuLevel1 | Select-Object -ExpandProperty SubFolders | Select-Object -ExpandProperty Folder)) {                        
            #Write-Host "`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name)" -ForegroundColor Cyan
            $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)"
            $Order = $MenuLevel2.Order
            $Url = ""
            $UrlType = ""
            MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType

            #Перечисляем подпапки lvl2
            if ($MenuLevel2.SubFolders -ne "") {
                foreach ($MenuLevel3 in ($MenuLevel2 | Select-Object -ExpandProperty SubFolders | Select-Object -ExpandProperty Folder)) {
                    #Write-Host "`t`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)" -ForegroundColor Gray                     
                    $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)"
                    $Order = $MenuLevel3.Order
                    $Url = ""
                    $UrlType = ""
                    MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType
                                           
                #Перечисляем подпапки lvl3
                if ($MenuLevel3.SubFolders -ne "") {
                    foreach ($MenuLevel4 in ($MenuLevel3 | Select-Object -ExpandProperty SubFolders | Select-Object -ExpandProperty Folder)) {
                        #Write-Host "`t`t`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)\$($MenuLevel4.Name)" -ForegroundColor Magenta
                        $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)\$($MenuLevel4.Name)"
                        $Order = $MenuLevel4.Order
                        $Url = ""
                        $UrlType = ""
                        MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType
                                                
                    } #end foreach Level4 Folders
                } #end if Level3 have Folders
            
                #Перечисляем файлы lvl3
                if ($MenuLevel3.AVFiles -ne "") {
                    foreach ($MenuLevel4 in ($MenuLevel3 | Select-Object -ExpandProperty AVFiles | Select-Object -ExpandProperty File)) {
                        #Write-Host "`t`t`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)\$($MenuLevel4.Name) (схема)" -ForegroundColor DarkCyan
                        $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)\$($MenuLevel4.Name)"
                        $Order = $MenuLevel4.Order
                        $Url = $MenuLevel4.Path
                        $UrlType = "PdiScheme"
                        MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType

                    } #end foreach Level4 Schemas
                } #end if Level3 have Schema

                } #end foreach Level3 Folders
            } #end if Level2 have Folders
               
            #Перечисляем файлы lvl2
            if ($MenuLevel2.AVFiles -ne "") {
                foreach ($MenuLevel3 in ($MenuLevel2 | Select-Object -ExpandProperty AVFiles | Select-Object -ExpandProperty File)) {
                    #Write-Host "`t`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name) (схема)" -ForegroundColor Blue
                    $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)\$($MenuLevel3.Name)"
                    $Order = $MenuLevel3.Order
                    $Url = $MenuLevel3.Path
                    $UrlType = "PdiScheme"
                    MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType

                } #end foreach Level3 Schemas
            } #end if Level2 have Schemas
        
        } #end foreach Level2 Folders
    } #end if Level1 have Folders

    #Перечисляем файлы lvl1
    if ($MenuLevel1.AVFiles -ne "") {
        foreach ($MenuLevel2 in ($MenuLevel1 | Select-Object -ExpandProperty AVFiles | Select-Object -ExpandProperty File)) {
            #Write-Host "`t\\I-DS/RO\MainMenu\Ванкорское месторождение\$($MenuLevel1.Name)\$($MenuLevel2.Name) (схема)" -ForegroundColor Yellow
            $PathName = "$($MenuLevel1.Name)\$($MenuLevel2.Name)"
            $Order = $MenuLevel2.Order
            $Url = $MenuLevel2.Path
            $UrlType = "PdiScheme"
            MenuElement -PathName $PathName -Order $Order -Url $Url -UrlType $UrlType

        } #end foreach Level2 Schemas
    } #end if Level1 have Schemas
     
} ##end foreach Level0 Folders

#$ElementList | Format-Table -Property Type, Path, AttributeDataReferenceProperties, Name, ElementTemplate, AttributeDataReference,  AttributeValueType, AttributeUOM, ttributeDisplayDigits
#($ElementList | Where-Object -Property type -eq Element).Count
($ElementList | Where-Object {$PSItem.Path -like '*НПС-1*' -and $PSItem.Type -eq 'Element'}) | Format-Table -Property Type, Path, AttributeDataReferenceProperties, Name, ElementTemplate, AttributeDataReference,  AttributeValueType, AttributeUOM, ttributeDisplayDigits
($ElementList | Where-Object -Property Path -like '*НПС-1*').Count
($ElementList | Where-Object {$PSItem.Path -like '*НПС-1*' -and $PSItem.Type -eq 'Element'}).Count
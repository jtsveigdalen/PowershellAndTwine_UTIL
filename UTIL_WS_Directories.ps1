param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\Temp\MS_WS\Adoption_Acc\Copilot-Role-Based-Deployment Adoption Kit"
)

function Get-FileCount($folder) {
    $files = Get-ChildItem -Path $folder -File
    return $files.Count
}

function Get-Files($folder) {
    $files = Get-ChildItem -Path $folder -File
    return $files
}

function Iterate-FolderStructure($folder, $indentLevel, [ref]$totalFileCount, [ref]$fileTypes) {
    $indent = '     ' * $indentLevel
    $folderName = $folder.Name
    $fileCount = Get-FileCount -folder $folder.FullName
    
    if ($indentLevel -eq 1) {
        Write-Host ""
    }
    
    Write-Host "$indent$folderName ($fileCount files)"
    
    $files = Get-Files -folder $folder.FullName
    foreach ($file in $files) {
        Write-Host "$indent     |_ $($file.Name)"
        $totalFileCount.Value++
        
        $extension = $file.Extension.ToLower()
        if ($fileTypes.Value.ContainsKey($extension)) {
            $fileTypes.Value[$extension]++
        } else {
            $fileTypes.Value[$extension] = 1
        }
    }
    
    $subFolders = Get-ChildItem -Path $folder.FullName -Directory
    foreach ($subFolder in $subFolders) {
        Iterate-FolderStructure -folder $subFolder -indentLevel ($indentLevel + 1) -totalFileCount $totalFileCount -fileTypes $fileTypes
    }
}

$totalFileCount = 0
$fileTypes = @{}

Iterate-FolderStructure -folder (Get-Item -Path $Path) -indentLevel 0 -totalFileCount ([ref]$totalFileCount) -fileTypes ([ref]$fileTypes)

$fileTypesOutput = ""
foreach ($type in $fileTypes.Keys) {
    $fileTypesOutput += " ${type}: $($fileTypes[$type]);"
}

# Remove the last semicolon
$fileTypesOutput = $fileTypesOutput.TrimEnd(';')
Write-Host "Total files: $totalFileCount of types $fileTypesOutput"

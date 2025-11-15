# install-provider.ps1
$providerVersion = "5.67.0"
$providerUrl = "https://releases.hashicorp.com/terraform-provider-aws/$providerVersion/terraform-provider-aws_${providerVersion}_windows_amd64.zip"

$destination = "$env:APPDATA\terraform.d\plugins\registry.terraform.io\hashicorp\aws\$providerVersion\windows_amd64"

Write-Host "Creating plugin directory..."
New-Item -ItemType Directory -Force -Path $destination | Out-Null

Write-Host "Downloading AWS provider version $providerVersion using WebClient..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($providerUrl, "$destination\aws-provider.zip")

Write-Host "Extracting provider files..."
Expand-Archive -Path "$destination\aws-provider.zip" -DestinationPath $destination -Force

Write-Host "Cleaning up zip file..."
Remove-Item "$destination\aws-provider.zip"

Write-Host "`nAWS Terraform provider installed successfully!"

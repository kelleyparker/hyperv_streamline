Future plans:
- I anticipate modularizing this script better.  Perhaps moving Show-SizeMenu, Show-Menu, Download-ISO, and Create-HyperVVM into their own ps1 files.  


Run this PowerShell script to select from one of several Linux ISOs to download.  The default download destination is your user's Downloads folder.  
Once the ISO is downloaded, you can create your Hyper-V VM.  The VM will be configured without Secure Boot and either 1 to 8 GB of RAM.
You can configure anywhere between 50gb and 600gb of hard drive space, in 50gb increments.

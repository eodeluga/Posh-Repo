# Import the functions into your scripts by dot sourcing them like these example

# Import function thats at the same relative path as your script
.".\WriteLog.ps1"

# Import function on some drive
."C:\functions\WriteLog.ps1"

# Import from a share
."\\cam-s-evs2\SERVICES-Staff$\Services\ITServices\OPERATIONS\PoSh Repo\functions\TimeOut.ps1"

# The above will get a warning about script not being trusted but you can get around that like this
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Confirm:$false -Force

<#
You may also have to Unblock the remote script file using Windows Explorer
Choose right click file, and select properties
Then under the Advanced button, tick and apply the Unblock tick box
#>
<#Start

Logoff-all-environments 

Great for when some idiot did not change the default GPO to kickusers out after X time. You know, after they change thier 
password, and one of the machines keeps locking your shit out, because someone at microsoft thought it would be a good
idea to leave the default session up for years. No shit, I found a user still logged on to a box for over a year, after we
fired him, incidentally, this was the same man who didn't set GPO to kick users out after X time. 


Written by Jonathan W.

For support contact jon2kx@gmail.com or use Set-PSDebug to find and fix issues.

WARNING: Your environment may require RPC to be on. If you recieve errors related to RPC Bind, you need to do the following.


reg add "\\ComputerName\HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC /t Reg_Dword /d 0x1 /f
And query to make sure the change took place:
PS H:\> reg query "\\adil-w7x32vm2\HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server
    AllowRemoteRPC    REG_DWORD    0x1

    These instructions come courtesy of http://www.adilhindistan.com/2014/01/fixing-quser-access-is-denied-error.html 

Sorry for the codesmell commentary, It's a script, it's not like it's an enterprise application. These are the breaks.

End#>
#USER DEFINED STATIC VARIABLES (Defined in uppercase vs Dynamic variables that are defined in lowercase)

# Array stored variables (list) of hostnames to operate on.
$A = @("host-name-01","host-name-02","host-name-03")
$B = @("host-name-01","host-name-02","host-name-03")
$C = @("host-name-01","host-name-02","host-name-03")
#$ ENVARY is an array that should evaluate command line arguments
$ENVARY= @("A","B","C")
# FQDN is a variable that should be set to your fully qualified domain name.suffix
$FULQUALDOM = "domain.suffix"
# USESSION is Use Session Enter your userid here, without the domain (Script must be run from within the target domain, unless you have DNS and Domain Trusts)
$LOGOFFUID = "usernamehere"
$CHOSEENV = Read-Host -Prompt 'Which environment are we running in? A, B, C? Please enter environment?'

#Conditional Evaluation

# Ensure that user chose an environment that was equal to array options.
if (($CHOSEENV -ne "A") -and ($CHOSEENV -ne "B") -and ($CHOSEENV -ne "C")){
    Write-Host "Selection was incorrect."
    exit
    }
else {
    Write-Host "$CHOSEENV was selected."         
# For each available environment in $ENVARY, compare to chosen environment, if a match occures store a variable $hostarray that evaluates to $X where X is equal to the chosen environment.
       foreach ($environment in $ENVARY) {
          if($environment -eq $CHOSEENV) {
             $hostarray = Write-Host "`$$CHOSEENV"              
       }
      }
   }
<# For each host in the hostarry (Which should evaluate to $A,$B, or $C (The array stored variables from before) check for logon, catch errors and evaluate if not 
logged on, skip, finally try to log that person out. #>
 foreach ($ehost in "$hostarray"){  
           
         try
         {
            Write-Host "Searching for $LOGOFFUID on $ehost.$FULQUALDOM" 
            $loggedon =  query user "$LOGOFFUID" /server:"$test.$FULQUALDOM"
            if($loggedon -ne ""){
              $usersession = (quser  /server:localhost) -replace '\s{2,}',','|ConvertFrom-Csv
         }
      
         }
         catch [NativeCommandError],[RemoteException]
         {
            Write-Host "$LOGOFFUID not found or host inaccessible on $ehost.$FULQUALDOM"
            $loggedoncheckerror = "False"
         }
      try
         {
         if($loggedon -eq ""){
            $SKIP="True"
         }           
         else {
            $loggedon = "True"
            $SKIP="False"
         }
         }
      finally
         {
            if ($loggedon -eq "True" -and $SKIP -eq "False"){
               Write-Host "$LOGOFFUID was found logged on to $ehost.$FULQUALDOM, attempting to log off user..."
               try
                  {
                  logoff "$usersesssion" /server:"$ehost"."$FULQUALDOM" /v
                  } 
               catch [RemoteException]
                  {
                  Write-Host "Exception Thrown for Failure "
                  }
                  }                     
            elseif(($loggedon -eq "True") -and ($SKIP -ne "False")){          
               Write-Host "Conditional Checks do not match, Skipping..."
               }   
                      
      }          
}

function SendMail() {

<#
.SYNOPSIS
Send-Mail function
Eugene Odeluga
     
.DESCRIPTION
Sends an email to specified recipient

.EXAMPLE
SendMail -TO "joe.bloggs@gov.us" -SUBJECT "They've found me" -FROM "jason.bourne@gov.us" -BODY "On the run" -SMTPSERVER "che-casarray.anglia.local"

.EXAMPLE
SendMail -TO "joe.bloggs@gov.us" -SUBJECT "They've found me" -FROM "jason.bourne@gov.us" -BODY "On the run" -SMTPSERVER "kickinass.com" -CC "mummy.bourne@home.us"

.EXAMPLE
SendMail -TO "joe.bloggs@gov.us" -SUBJECT "They've found me" -FROM "jason.bourne@gov.us" -BODY "On the run" -SMTPSERVER "kickinass.com" -CC "mummy.bourne@home.us" -BCC "edward.snowden@therussianembassy.com"

.NOTES
NONE

#>





    Param ( 
            # email attributes
            [Parameter(mandatory=$true)]
            $TO,
            [Parameter(mandatory=$true)]
            $SUBJECT,
            [Parameter(mandatory=$true)]
            $BODY,
            [Parameter(mandatory=$true)]
            $FROM,
            $CC,
            $BCC,
            $SMTPSERVER = "your.mail.server"
    )
   
    if (($CC -ne $null) -and ($BCC -ne $null)) {
        # Send mail with CC and BCC
        try {
            Send-MailMessage -To $TO -Subject $SUBJECT -BodyAsHtml $BODY -From $FROM `
                -SmtpServer $SMTPSERVER -Cc $CC -Bcc $BCC
        } catch {
            WriteLog
        }
    } elseif (($CC -ne $null) -and ($BCC -eq $null)) {
        # Send mail with CC
        try {
            Send-MailMessage -To $TO -Subject $SUBJECT -BodyAsHtml $BODY -From $FROM `
                -SmtpServer $SMTPSERVER -Cc $CC
        } catch {
            WriteLog
        }
    } elseif (($BCC -ne $null) -and ($CC -eq $null)) {
        # Send mail with BCC
        try {
            Send-MailMessage -To $TO -Subject $SUBJECT -BodyAsHtml $BODY -From $FROM `
                -SmtpServer $SMTPSERVER -Bcc $BCC
        } catch {
            WriteLog
        }
    } else {
        # Send mail
        try {
            Send-MailMessage -To $TO -Subject $SUBJECT -BodyAsHtml $BODY -From $FROM `
                -SmtpServer $SMTPSERVER
        } catch {
            WriteLog
        }
    }
}
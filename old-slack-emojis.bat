@ECHO OFF

:: User input

SET "UNINSTALL="
SET "SLACK_DIR="

:parse
IF "%~1" == "" GOTO endparse
IF "%~1" == "-u" (
	SET UNINSTALL=%~1
) ELSE (
	SET SLACK_DIR=%~1
)
SHIFT
GOTO parse
:endparse

:: Try to find slack if not provided by user

IF "%SLACK_DIR%" == "" (
	FOR /F %%t IN ('DIR /B /OD "%UserProfile%\AppData\Local\slack\app-?.*.*"') DO (
		SET SLACK_DIR=%UserProfile%\AppData\Local\slack\%%t\resources\app.asar.unpacked\src\static
	)
)


:: Check so installation exists

IF "%SLACK_DIR%" == "" (
	ECHO Cannot find Slack installation.
	PAUSE & EXIT /B 1
)

IF NOT EXIST "%SLACK_DIR%" (
	ECHO Cannot find Slack installation at: %SLACK_DIR%
	PAUSE & EXIT /B 1
)

IF NOT EXIST "%SLACK_DIR%\ssb-interop.js" (
	ECHO Cannot find Slack file: %SLACK_DIR%\ssb-interop.js
	PAUSE & EXIT /B 1
)


ECHO Using Slack installation at: %SLACK_DIR%


:: Remove previous version

IF EXIST "%SLACK_DIR%\old-slack-emojis.js" (
	DEL "%SLACK_DIR%\old-slack-emojis.js"
)


:: Restore previous injections

CALL :restore_file "%SLACK_DIR%\ssb-interop.js"
IF %ERRORLEVEL% NEQ 0 ( PAUSE & EXIT /B 1 )


:: Are we uninstalling?

IF "%UNINSTALL%" == "-u" (
	ECHO Old Slack emojis have been uninstalled. Please restart the Slack client.
	PAUSE & EXIT /B 0
)


:: Write main script

>"%SLACK_DIR%\old-slack-emojis.js" (
    ECHO.var emojiStyle = document.createElement('style'^);
    ECHO.emojiStyle.innerText = ".emoji-outer { background-image: url('https://old-slack-emojis.cf/cdn/slack_2016_apple_sprite_64.png') !important; }";
    ECHO.document.head.appendChild(emojiStyle^);
)


:: Inject code loader

CALL :inject_loader "%SLACK_DIR%\ssb-interop.js"
IF %ERRORLEVEL% NEQ 0 ( PAUSE & EXIT /B 1 )


:: We're done

ECHO Old Slack emojis have been installed. Please restart the Slack client.
PAUSE & EXIT /B 0


:: Functions

:restore_file
FINDSTR /R /C:"old-slack-emojis" "%~1" >NUL
IF %ERRORLEVEL% EQU 0 (
	IF EXIST "%~1.osebak" (
		MOVE /Y "%~1.osebak" "%~1" >NUL
	) ELSE (
		ECHO Cannot restore from backup. Missing file: %~1.osebak
		EXIT /B 1
	)
) ELSE (
	IF EXIST "%~1.osebak" (
		DEL "%~1.osebak"
	)
)
EXIT /B 0
:: end restore_file


:inject_loader
:: Check so not already injected
FINDSTR /R /C:"old-slack-emojis" "%~1" >NUL
IF %ERRORLEVEL% EQU 0 (
	ECHO File already injected: %~1
	EXIT /B 1
)

:: Make backup
IF NOT EXIST "%~1.osebak" (
	COPY "%~1" "%~1.osebak" >NUL
) ELSE (
	ECHO Backup already exists: %~1.osebak
	EXIT /B 1
)

:: Inject loader code
>>"%~1" (
	ECHO.
	ECHO.// ** old-slack-emojis ** https://github.com/IvyBits/old-slack-emojis
	ECHO.var scriptPath = path.join(__dirname, 'old-slack-emojis.js'^).replace('app.asar', 'app.asar.unpacked'^);
	ECHO.require('fs'^).readFile(scriptPath, 'utf8', (e, r^) =^> { if (e^) { throw e; } else { eval(r^); } }^);
)

EXIT /B 0
:: end inject_loader

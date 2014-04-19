@echo off
cd "%~dp0"
set choice=C:\Windows\system32\choice.exe
cls

::::::::::::::::::::::::::::::::
:: Zipalign / Signing script  ::
:: Made by aureljared.        ::
::                            ::
:: (C) 2014. DO NOT REMOVE    ::
:: CREDITS.                   ::
::::::::::::::::::::::::::::::::

:get
echo [] Enter the name of the apk you want to sign.
echo [] Example: SystemUI
echo []
echo [] NOTE: What you enter here will also be the filename
echo []       of the final APK. Case-sensitive.
set /p input="Filename: " %=%
IF EXIST %input%.apk (
goto sign
) ELSE (
goto error
)

:sign
echo [] Signing APK...
java -jar signapk.jar testkey.x509.pem testkey.pk8 %input%.apk temp.apk
IF EXIST temp.apk (
goto zipalign
) ELSE (
goto error
)
goto sign

:error
echo [] Input / Temporary / Final APK not found.
pause
exit

:zipalign
cls
echo [] Zipaligning...
del %input%.apk
zipalign -f -v 4 temp.apk %input%.apk
IF EXIST %input%.apk (
goto last
) ELSE (
goto error
)
goto zipalign

:last
cls
echo [] Removing temporary files...
del temp.apk
echo [] Done.
pause
exit
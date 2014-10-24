@echo off
setlocal EnableDelayedExpansion

goto :L_CONFIG_LOG

:L_HELP
    echo.
    echo.
    echo USAGE: 
    echo     coverEar.bat [/r ^<COUNT^>] ^<SOURCE^> ^<DEST^>
    echo     Copy one or more files to another location. It's the same
    echo     with copy command in cmd.exe. 
    echo.
    echo OPTIONS:
    echo        /r: If it's failed, there would be retries, the default 
    echo            retry times is 10, you could set in the cmd line, 
    echo            e.g., 
    echo                coverEar.bat /r 50 savelog.zip D:\
    echo    SOURCE: The source file(s^) or folder that to be copied, 
    echo            wildcard could be used, e.g.,:
    echo                coverEar.bat *.jpg D:\
    echo      DEST: Specified the directory and/or filename for the new
    echo            file(s^)
    echo.
    goto :L_EXIT

:L_CONFIG_LOG
    if "%TEMP%" EQU "" (
        set ERROR_LOG=coverEar.err
        set NORMAL_LOG=coverEar.log
        set FILE_LIST=coverEar_file.lst
        set FAILED_FILE_LIST=coverEar_failed.lst
        set TEMP_FILE=coverEar.tmp
    ) else (
        set ERROR_LOG=%TEMP%\coverEar.err
        set NORMAL_LOG=%TEMP%\coverEar.log
        set FILE_LIST=%TEMP%\coverEar_file.lst
        set FAILED_FILE_LIST=coverEar_failed.lst
        set TEMP_FILE=%TEMP%\coverEar.tmp
    )

    rem Clean the list file first
    if exist %ERROR_LOG%        del %ERROR_LOG%
    if exist %NORMAL_LOG%       del %NORMAL_LOG%
    if exist %FILE_LIST%        del %FILE_LIST%
    if exist %FAILED_FILE_LIST% del %FAILED_FILE_LIST%
    if exist %TEMP_FILE%        del %TEMP_FILE%

:L_EVAL_PARAM
    shift
    if "%0" EQU ""      goto :L_END_EVAL_PARAM
    if "%0" EQU "/r"    goto :L_SET_RETRY
    goto :L_SET_SOURCE_AND_DEST

:L_SET_RETRY
    set /A RETRY=%1
    shift
    goto :L_EVAL_PARAM

:L_SET_SOURCE_AND_DEST
    set SOURCE=%0
    if "%1" EQU "" (
        echo Destination not set.
        goto :L_HELP
    ) else (
        set DEST=%1
    )
    goto :L_END_EVAL_PARAM

:L_END_EVAL_PARAM

:L_CHECK_PARAM
    if "%SOURCE%" EQU "" (
        goto :L_HELP
    ) 

    if not exist %SOURCE% (
        echo Can not find: %SOURCE%
        echo Please check whether the source path is right.
        goto :L_HELP
    )
    rem Store all the files into a list
    rem The way to get the directory of the source, it's based
    rem on the output of dir command.
    for /f "tokens=3" %%i in ('"dir %SOURCE% | findstr "Directory of" "') do set FOLDER=%%i\
    for /f %%i in ('dir /B %SOURCE%') do (echo !FOLDER!%%i >> %FILE_LIST%)

    if "%DEST%" EQU "" goto :L_HELP
    rem Default retry is 10.
    if "%RETRY%" EQU "" set RETRY=10

:L_START_COMMAND
    rem for could not be used here because we need to check the 
    rem errorlevel everytime, however if for is used, errorlevel
    rem would be expanded at the very early stage and the loop 
    rem would continue whatever the copy command succeeded or not.
    for /f %%i in (%FILE_LIST%) do (
        echo %%i

        set /A COUNT=1
:L_START_COPY_ONE
        echo call copy /Z %%i %DEST% 2>%ERROR_LOG%
        cd sdagsdag
        if !errorlevel! EQU 0 goto :L_EXIT
        if !COUNT! NEQ %RETRY% (
            echo Retrying ... !COUNT!
            set /A COUNT+=1
            goto :L_START_COPY_ONE
        ) else (
            echo Failed to copy from %%i to %DEST% for %RETRY% times.
            echo %%i >> %FAILED_FILE_LIST%
        )
    )

:L_EXIT
    rem Only if the log file is stored in current folder that we 
    rem would clean it. If it's stored in the TEMP folder, we would
    rem leave it.
    if exist %ERROR_LOG% (
        if "%TEMP%" EQU "" (
            rem call del %ERROR_LOG%
            rem call del %NORMAL_LOG%
            rem call del %FILE_LIST%
            rem call del %FAILED_FILE_LIST%
            rem call del %TEMP_FILE%
        )
    )

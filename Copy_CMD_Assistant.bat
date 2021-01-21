@echo off

::     ABOUT ME
REM      Name:  Ariel Montes
REM      Website: montesariel.com

::     INFORMATION
REM      The utility of this script is to copy all the files from a specific directory and its
REM      subdirectories to a second given directory, separating the files into folders of a
REM      specific dimension without compromising the integrity of the files or cutting them.
REM      How? after copying each file it renames it to avoid being overwritten in case more
REM      files share the same name in other subdirectories and it is also able to deal with
REM      file names that use spaces or other special characters.

::     REQUIREMENTS
REM      Windows Operating System

::     DETAILS
REM      The tests have been carried out in Windows 10 Pro - Version 20H2.
REM      The only case in which a folder can exceed the maximum size set is if a file exceeds 
REM      that size, to preserve its integrity it will be copied to a new folder.

::     DEBUG
REM      Prevents the program from closing in the event of an error allowing messages to be read
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )


::     SETTINGS
REM Desired dimension per folder (current value 50 MB in binary bytes)
set maxSize=52428800
REM Directory of files to copy
set source=
REM Directory where to copy the files
set dest=
REM Name prefix for generated folders (followed by an increasing number)
set FolderName=dir_
REM Name prefix for copied files (followed by an increasing number)
set FileName=file_


::     PROGRAM
setlocal EnableDelayedExpansion

REM Iterate in the different files of the directory and its subdirectories
for /f "delims=" %%f in ('dir /a-d /b /s %source%') do (

    REM Current sum of files in byte
    set CurrentSize=!size!
	
    REM Control of file sizes in bytes
    for /f "usebackq delims=" %%s in ('%%f') do (  
        REM Current file size
        set FileSize=%%~zs
        if !FileSize! LSS %maxSize% (
            REM Sum of all files (temporary)
            set /a TemporalSize=!size!+!FileSize!
            REM Sum of all files (definitive)
            if !TemporalSize! LSS %maxSize% (set /a size+=!FileSize!)
        )
    )
	
	REM If the dimension of the files and the current file are less than the specified maximum
    if !TemporalSize! LSS %maxSize% (
        if !FileSize! LSS %maxSize% (
            REM Add filename to list
            if "!FileList!" EQU "" (set FileList="%%f") else (set FileList=!FileList! "%%f")
		)
    )
	
	REM If the dimension of the files is greater than the specified maximum
    if !TemporalSize! GTR %maxSize% (
        set /a FolderNumb+=1
		REM Create new folder
		if not exist "%dest%\%FolderName%!FolderNumb!" mkdir "%dest%\%FolderName%!FolderNumb!"
        set /a fdrSize=!CurrentSize!/1048576
        echo._________________________________
        echo Folder: %FolderName%!FolderNumb!  Size: ~!fdrSize!MB
        echo.
		REM Copy the files
		set CopyNumb=0
		for %%i in (!FileList!) do (
			for /f "tokens=*" %%o in ('copy %%i "%dest%\%FolderName%!FolderNumb!"') do (
				set output=%%o
				set status=!output:~0,1!
				if /i !status! EQU 1 (
					set /a CopyNumb+=1
					set /a FileNumb+=1
					if not exist "%dest%\%FolderName%!FolderNumb!\!FileName!!FileNumb!%%~xi" (
						REM Rename file
						ren "%dest%\%FolderName%!FolderNumb!\%%~ni%%~xi" "!FileName!!FileNumb!.*"
					) else (
						echo Could not rename file "%%~ni%%~xi" to "!FileName!!FileNumb!%%~xi" because "!FileName!!FileNumb!%%~xi" already exist in folder "%FolderName%!FolderNumb!"
					)
				) else (echo !output!: %%i)
			)
		)
		if /i !CopyNumb! GTR 1 echo !CopyNumb! files copied
		if /i !CopyNumb! EQU 1 echo 1 file copied
		
        REM Reset values
        set FileList=
        set size=0
        REM Save the current file that exceeds
        if !FileSize! LSS %maxSize% (
            set FileList="%%f"
            set size=!FileSize!
        )
    )
	
	REM If the current file dimension is greater than the specified maximum
    if !FileSize! GTR %maxSize% (
        set /a FolderNumb+=1
		if not exist "%dest%\%FolderName%!FolderNumb!" mkdir "%dest%\%FolderName%!FolderNumb!"
        set /a fdrSize=!FileSize!/1048576
        echo._________________________________
        echo Folder: %FolderName%!FolderNumb!  Size: ~!fdrSize!MB
		echo.
		for %%i in (%%f) do (
			REM Copy the current file to a separate folder
			for /f "tokens=*" %%o in ('copy "%%f" "%dest%\%FolderName%!FolderNumb!"') do (
				set output=%%o
				set status=!output:~0,1!
				if /i !status! EQU 1 (
					echo 1 file copied
					set /a FileNumb+=1
					if not exist "%dest%\%FolderName%!FolderNumb!\!FileName!!FileNumb!%%~xi" (
						REM Rename file
						ren "%dest%\%FolderName%!FolderNumb!\%%~ni%%~xi" "!FileName!!FileNumb!.*"
					) else (
						echo Could not rename file "%%~ni%%~xi" to "!FileName!!FileNumb!%%~xi" because "!FileName!!FileNumb!%%~xi" already exist in folder "%FolderName%!FolderNumb!"
					)
				) else (echo !output!: %%i)
			)
		)
    )
)

REM Copy the remaining files at the end of the loop
if "%FileList%" NEQ "" (
    set /a FolderNumb+=1
	if not exist "%dest%\%FolderName%!FolderNumb!" mkdir "%dest%\%FolderName%!FolderNumb!"
    set /a fdrSize=!size!/1048576
    echo._________________________________
    echo Folder: %FolderName%!FolderNumb!  Size: ~!fdrSize!MB
	echo.
	set CopyNumb=0
	for %%i in (!FileList!) do (
		for /f "tokens=*" %%o in ('copy %%i "%dest%\%FolderName%!FolderNumb!"') do (
			set output=%%o
			set status=!output:~0,1!
			if /i !status! EQU 1 (
				set /a CopyNumb+=1
				set /a FileNumb+=1
				if not exist "%dest%\%FolderName%!FolderNumb!\!FileName!!FileNumb!%%~xi" (
					REM Rename file
					ren "%dest%\%FolderName%!FolderNumb!\%%~ni%%~xi" "!FileName!!FileNumb!.*"
				) else (
					echo Could not rename file "%%~ni%%~xi" to "!FileName!!FileNumb!%%~xi" because "!FileName!!FileNumb!%%~xi" already exist in folder "%FolderName%!FolderNumb!"
				)
			) else (echo !output!: %%i)
		)
	)
	if /i !CopyNumb! GTR 1 echo !CopyNumb! files copied
	if /i !CopyNumb! EQU 1 echo 1 file copied
)

endlocal

echo.
pause
exit
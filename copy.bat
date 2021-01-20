@echo off

::     INFORMACION DEL CREADOR
REM      NOMBRE:  Ariel Montes
REM      WEBSITE: montesariel.com

::     REQUERIMIENTOS
REM      Sistema Operativo Windows

::     INSTRUCCIONES DE USO
REM      Es aconsejable cambiar los nombres de las imagenes a copiar "ctrl+a > f2 > del > enter"
REM      y luego de nuevo "ctrl+a f2 > flecha-izquierda > del" esto hara que todas las
REM      imagenes tengan por nombre un numero y evitar conflictos con los nombres de archivo.

::     INFORMACION
REM      Los test han sido efectuados en Windows 10 Pro - Version 20H2.
REM      Para que el programa funcione correctamente es necesario que los nombres de los
REM      archivos no contengan ni espacios ni caracteres que no sean de tipo ASCII.
REM      El control de los nombres de archivos deberia ser objeto de una futura
REM      mejora o implementacion del codigo existente.


::     DEBUG
REM Previene que el programa se cierre en caso de error permitiendo leer los mensajes
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )


::     CONFIGURACION
REM Dimencion de archivos deseada por carpeta en bytes binary, valor actual 50MB
set maxSize=52428800
REM Directorio de las imagenes
set source=D:\Directorio\Proveniencia\Imagenes
REM Directorio donde copiar los archivos
set dest=D:\Directorio\Destino
REM Nombre de las carpetas generadas
set folder=img_


::     PROGRAMA
REM Archivos a copiar
set files=
REM Suma de archivos en bytes
set size=0
REM Dimencion carpeta creada
set fdrSize=0
REM Numero de carpeta
set fNum=0

setlocal EnableDelayedExpansion

REM Itera en los diferentes archivos del directorio
for %%f in (%source%\*) do (
	
	REM Suma de archivos en byte temporal
	set tSize=0
	REM Bytes del archivo actual
	set fSize=0
	REM Suma de archivos en byte actual
	set cSize=!size!
	
	REM Control bytes de archivos
	for /F "usebackq tokens=* delims=" %%s in ('%%f') do (	
		REM Bytes del archivo actual
		set /a fSize=%%~zs
		if !fSize! LSS %maxSize% (
			REM Suma temporal de los bytes
			set /a tSize=!size!+!fSize!
			REM Suma definitiva de los bytes
			if !tSize! LSS %maxSize% (set /a size+=!fSize!)
		)
	)
	
	REM Si la dimencion de los archivos y del archivo actual son inferiores al maximo especificado
	if !tSize! LSS %maxSize% (
		if !fSize! LSS %maxSize% (
			REM Suma nombre de archivo a la lista
			set files=!files! "%%~nxf"
		)
	)
	
	REM Si la dimencion de los archivos es superior al maximo especificado
	if !tSize! GTR %maxSize% (
		REM Copia los archivos
		set /a fNum+=1
		set /a fdrSize=!cSize!/1048576
		echo._________________________________
		echo folder %folder%!fNum!  size ~!fdrSize!MB
		robocopy %source% %dest%\%folder%!fNum! !files! /NJH /NJS /nc /ns | find /v "\"
		REM Reinicia valores
		set files=
		set size=0
		REM Reinicia valores guardando archivo actual que excede
		if !fSize! LSS %maxSize% (
			set files="%%~nxf"
			set size=!fSize!
		)
	)
	
	REM Si la dimencion del archivo actual es superior al maximo especificado
	if !fSize! GTR %maxSize% (
		REM Copia el archivo actual en una carpeta aparte
		set /a fNum+=1
		set /a fdrSize=!fSize!/1048576
		echo._________________________________
		echo folder %folder%!fNum!  size ~!fdrSize!MB
		robocopy %source% %dest%\%folder%!fNum! "%%~nxf" /NJH /NJS /nc /ns | find /v "\"
	)
)

REM Copia los archivos restantes al terminar el loop
if "%files%" NEQ "" (
	set /a fNum+=1
	set /a fdrSize=!size!/1048576
	echo._________________________________
	echo folder %folder%!fNum!  size ~!fdrSize!MB
	robocopy %source% %dest%\%folder%!fNum! !files! /NJH /NJS /nc /ns | find /v "\"
)

endlocal

echo.
pause
exit

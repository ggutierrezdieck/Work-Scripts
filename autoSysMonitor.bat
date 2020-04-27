REM script monitors a list of jobs, provided in a file, and display its status
@echo off
setlocal EnableDelayedExpansion

Rem Variables
set filename=jobs.txt
set /a i=0
set status=''
set currentJob=''
set arrLen=0
   


REM Getting job names from filename
for /f "usebackq delims=" %%l in (%filename%) do (
	call set jobs[%%i%%]=%%l
	call set arrLen=%%i%%
	set /a i+=1
)



REM Autosys Configurations
set AUTOSERV=P00
set SERVER1=
set SERVER2=

c:
cd \Program Files (x86)\Barclays Capital\AutoSys_tools_x64\bin



set /a i=0
:while
	set currentJob=!jobs[%i%]!

	REM continously checking if the job has completed
	timeout /nobreak /t 6
	echo.
	echo Checking job %currentJob%
	FOR /F "delims=" %%i IN ( '.\AUTOSTATUS.cmd -j  %currentJob%' ) DO ( set status=%%i )
	echo %currentJob% is %status%

	REM clearing the status flag
	set status=''
	set /a i = %i% + 1
	REM reseting counter after reaching last job, and waiting some timbe before continuing
	if %i% gtr %arrlen% (
		set i=0
	)
goto while


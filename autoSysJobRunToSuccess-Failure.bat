REM  Script will force start a job, and monitor until succes or failure. Then it will force start next job and so on.
@echo off
setlocal EnableDelayedExpansion

Rem Variables
set filename=etdJobs.txt
set i=0
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



set i=0
:while
	set currentJob=!jobs[%i%]!
	REM Checking if job is not running before starting it
	FOR /F "delims=" %%i IN ( '.\AUTOSTATUS.cmd -j  %currentJob%' ) DO ( set status=%%i )
	if %status%==RUNNING  goto skipRun
	echo.
	echo ABOUT TO START THE JOB %currentJob%
		REM Starting job
	FOR /F "delims=" %%i IN ( '.\SENDEVENT.cmd -E FORCE_STARTJOB -J  %currentJob%' ) DO ( echo  %currentJob% STARTED )
	  
	
	REM continously checking if the job has completed
	:loop
		timeout /nobreak /t 6
		echo.
		echo Checking job %currentJob%
		FOR /F "delims=" %%i IN ( '.\AUTOSTATUS.cmd -j  %currentJob%' ) DO ( set status=%%i )

	:skipRun
		if %status%==FAILURE (
			echo %currentJob% is %status% && goto next
		) else (
			if not %status%==SUCCESS (
				echo %currentJob% is %status% && goto loop
			)
		)
	:next
	REM clearing the status flag
	set status=''
	set /a i = %i% + 1
	REM reseting counter after reaching last job, and waiting some timbe before continuing
	if %i% gtr %arrlen% (
		goto end
	)
goto while
:end


pause
REM script will force start a list of jobs  provided on a file
@echo off
setlocal EnableDelayedExpansion


Rem Variables
set filename=jobs.txt
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
set AUTOSERV=P50
set SERVER1=
set SERVER2=

c:
cd \Program Files (x86)\Barclays Capital\AutoSys_tools_x64\bin


:while
	set currentJob=!jobs[%i%]!
	REM Checking if job is not running before starting it
	FOR /F "delims=" %%i IN ( '.\AUTOSTATUS.cmd -j  %currentJob%' ) DO ( set status=%%i )
	if %status%==RUNNING %status% && goto next
	echo.
	echo ABOUT TO START THE JOB %currentJob%
		REM Starting job
	FOR /F "delims=" %%i IN ( '.\SENDEVENT.cmd -E FORCE_STARTJOB -J  %currentJob%' ) DO ( echo  %currentJob% STARTED )
	  
	
	REM continously checking if the job has completed
	:loop
		timeout /nobreak /t 10'
		echo Checking job %currentJob%
		FOR /F "delims=" %%i IN ( '.\AUTOSTATUS.cmd -j  %currentJob%' ) DO ( echo %currentJob% is %status% )
		 
	:next
	REM  if Not %status%==SUCCESS echo %currentJob% is %status% && goto loop
	
	REM clearing the status flag
	set status=''
	set /a i = %i% + 1
	REM reseting counter after reaching last job, and waiting some timbe before continuing
	if %i% gtr %arrlen% (
		goto exit
	)
goto while

:exit
echo. 
echo All jobs have been force started
pause


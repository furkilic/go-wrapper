@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM GO Start Up Batch script
@REM
@REM Optional ENV vars
@REM   GOROOT=/app/go - if go already installed locally
@REM   GO_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM   GOW_VERBOSE=true - to make it verbose
@REM   GOW_REPOURL=https://dl.google.com/go - default REPOURL
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case GO_BATCH_ECHO is 'on'
@echo off
@REM set title of command window
title %0
@REM enable echoing by setting GO_BATCH_ECHO to 'on'
@if "%GO_BATCH_ECHO%" == "on"  echo %GO_BATCH_ECHO%

@REM set %HOME% to equivalent of $HOME
if "%HOME%" == "" (set "HOME=%HOMEDRIVE%%HOMEPATH%")

@setlocal

set ERROR_CODE=0

@REM To isolate internal variables from possible post scripts, we use another setlocal
@setlocal

if NOT "%GOROOT%"==""  goto run

@REM ==== END VALIDATION ====

:init

@REM Find the project base dir, i.e. the directory that contains the folder ".mvn".
@REM Fallback to current working directory if not found.

set GO_PROJECTBASEDIR=%GO_BASEDIR%
IF NOT "%GO_PROJECTBASEDIR%"=="" goto endDetectBaseDir

set EXEC_DIR=%CD%
set WDIR=%EXEC_DIR%
:findBaseDir
IF EXIST "%WDIR%"\.go goto baseDirFound
cd ..
IF "%WDIR%"=="%CD%" goto baseDirNotFound
set WDIR=%CD%
goto findBaseDir

:baseDirFound
set GO_PROJECTBASEDIR=%WDIR%
cd "%EXEC_DIR%"
goto endDetectBaseDir

:baseDirNotFound
set GO_PROJECTBASEDIR=%EXEC_DIR%
cd "%EXEC_DIR%"

:endDetectBaseDir

set GO_WRAPPER_PATH="%GO_PROJECTBASEDIR%\.go\wrapper"
set GO_WRAPPER_PROPERTIES=%GO_PROJECTBASEDIR%\.go\wrapper\go-wrapper.properties
set GO_INSTALL_PATH=%GO_PROJECTBASEDIR%\.go\wrapper\go
set GO_TMP_PATH="%GO_PROJECTBASEDIR%\.go\wrapper\tmp"
set GO_WRAPPER_DATE="%GO_PROJECTBASEDIR%\.go\wrapper\go\go.date"
set GO_VERSION_URL="https://go.dev/dl/"
set GO_VERSION_PATH="%GO_PROJECTBASEDIR%\.go\wrapper\tmp\go.version"
set GO_ZIP_PATH="%GO_PROJECTBASEDIR%\.go\wrapper\tmp\go.zip"

set DOWNLOAD_URL_BASE=https://dl.google.com/go
set DOWNLOAD_URL=%DOWNLOAD_URL%

if not exist "%GO_WRAPPER_PROPERTIES%" goto extension
FOR /F "tokens=1,2 delims==" %%A IN (%GO_WRAPPER_PROPERTIES%) DO (
    IF "%%A"=="distributionUrl" SET DOWNLOAD_URL=%%B
    IF "%%A"=="goVersion" SET GO_LATEST_VERSION=%%B
)

@REM Extension to allow automatically downloading GO
@REM This allows using the go-wrapper in projects that prohibit checking in binary data.
:extension
if exist %GO_WRAPPER_DATE%  goto goInstalled


mkdir %GO_TMP_PATH%
if not "%GOW_REPOURL%" == ""  SET DOWNLOAD_URL_BASE=%GOW_REPOURL%

if "%GOW_VERBOSE%" == "true" (
    echo Couldn't find %GO_INSTALL_PATH%, downloading it ...
    echo Downloading from: %DOWNLOAD_URL_BASE%
)

if exist %GO_ZIP_PATH% goto goZipDownloaded
if not "%DOWNLOAD_URL%" == "" goto goZipDownloadUrlReady
if not "%GO_LATEST_VERSION%" == "" goto buildDownloadUrl

@REM BAD Hack to retrieve latest version

powershell -Command "&{"^
    "$webclient = new-object System.Net.WebClient;"^
    "if (-not ([string]::IsNullOrEmpty('%GOW_USERNAME%') -and [string]::IsNullOrEmpty('%GOW_PASSWORD%'))) {"^
    "$webclient.Credentials = new-object System.Net.NetworkCredential('%GOW_USERNAME%', '%GOW_PASSWORD%');"^
    "}"^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%GO_VERSION_URL%', '%GO_VERSION_PATH:~1,-1%')"^
    "}"
for /f "tokens=*" %%a in ('findstr /R "toggleVisible" %GO_VERSION_PATH%') do (
    for /f "tokens=3delims==" %%i in ("%%a") do (
      echo %%i>>%GO_VERSION_PATH%.tmp
    )
)

set /pGO_LATEST_VERSION=<%GO_VERSION_PATH%.tmp
set GO_LATEST_VERSION=%GO_LATEST_VERSION:~3,-2%

DEL %GO_VERSION_PATH%.tmp
DEL %GO_VERSION_PATH%

:buildDownloadUrl
set GO_DOWNLOAD_ARCH=amd64
echo %PROCESSOR_ARCHITECTURE% | find /i "x86" > nul
if %ERRORLEVEL%==0 set GO_DOWNLOAD_ARCH=386

set DOWNLOAD_URL="%DOWNLOAD_URL_BASE%/go%GO_LATEST_VERSION%.windows-%GO_DOWNLOAD_ARCH%.zip"

:goZipDownloadUrlReady
powershell -Command "&{"^
    "$webclient = new-object System.Net.WebClient;"^
    "if (-not ([string]::IsNullOrEmpty('%GOW_USERNAME%') -and [string]::IsNullOrEmpty('%GOW_PASSWORD%'))) {"^
    "$webclient.Credentials = new-object System.Net.NetworkCredential('%GOW_USERNAME%', '%GOW_PASSWORD%');"^
    "}"^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%DOWNLOAD_URL%', '%GO_ZIP_PATH:~1,-1%')"^
    "}"
if "%GOW_VERBOSE%" == "true" (
    echo Finished downloading %GO_ZIP_PATH%
)

:goZipDownloaded
if "%GOW_VERBOSE%" == "true" (
   echo Found %GO_ZIP_PATH%
)
powershell -Command "Expand-Archive -Force '%GO_ZIP_PATH:~1,-1%' '%GO_WRAPPER_PATH:~1,-1%'"
echo %date% > %GO_WRAPPER_DATE%
if "%GOW_VERBOSE%" == "true" (
    echo Finished unpacking %GO_ZIP_PATH%
)

:goInstalled
if "%GOW_VERBOSE%" == "true" (
    echo Found %GO_INSTALL_PATH%
)

set GOROOT=%GO_INSTALL_PATH%

@REM Set GOPATH in case there is none 
if "%GOPATH%" == "" (
    for /f %%i in ('%GOROOT%\bin\go env GOPATH') do set GOPATH=%%i
)
@REM End of extension

@REM Provide a "standardized" way to retrieve the CLI args that will
@REM work with both Windows and non-Windows executions.
:run
set GO_CMD_LINE_ARGS=%*

@REM Export Go Variables for downstream executions
set "PATH=%GOROOT%\bin;%GOPATH%\bin;%PATH%"

if "%1" == "printenv" (
    echo set GOROOT=%GOROOT%
    echo set GOPATH=%GOPATH%
    echo set PATH=%%GOROOT%%\bin;%%GOPATH%%\bin;%%PATH%%
    echo:
    echo # Run this command to configure your shell: copy and paste the above values into your command prompt
) else (
    %GOROOT%\bin\go %*
)

if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%
@REM pause the script if MAVEN_BATCH_PAUSE is set to 'on'
if "%GOW_BATCH_PAUSE%" == "on" pause

exit /B %ERROR_CODE%
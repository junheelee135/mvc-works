@echo off
cd /d %~dp0
echo ====================================
echo  mvc-works Spring Boot 실행
echo ====================================
call gradlew.bat bootRun
pause

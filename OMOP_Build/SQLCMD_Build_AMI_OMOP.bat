::Execute a stored procedure on a SQL server
::https://stackoverflow.com/questions/12980353/execute-stored-procedure-from-batch-file

REM Start
c:
cd \Windows\system32
SQLCMD -S DH5772\RSR -E -d OMOP_CDM -Q "uspOMOPBuild" -o D:\GitRepos\AMI_OMOP\OMOP_Build\SQLCMDLog.txt

REM End

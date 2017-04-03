﻿function Reset-tssServiceBroker
{
    [CmdletBinding()]
    param (
    [parameter(Mandatory=$true)]
    [string] $Environment,
    [parameter(Mandatory=$true)]
    [string] $SubEnvironment,
    [switch] $SkipPWB
    )

    $DBServer = Get-tssConnection -Environment $Environment
    
    [string]$PLSDB = Get-tssDatabaseName -SQLServer $DBServer -Environment $Environment -SubEnvironment $SubEnvironment -Database PLS
    if ($PLSDB -eq $null -or $PLSDB.Trim() -eq '') {
        Write-Error "No es posible conectar a la base de datos PLS"
        return $null
    }
    
    if ($SkipPWB -eq $false){
        [string]$PWBDB = Get-tssDatabaseName -SQLServer $DBServer -Environment $Environment -SubEnvironment $SubEnvironment -Database PLSPWB
        if ($PWBDB -eq $null -or $PWBDB.Trim() -eq '') {
            Write-Error "No es posible conectar a la base de datos PWB"
            return $null
        }
    }

    [string]$plssql = "ALTER DATABASE $PLSDB SET NEW_BROKER WITH ROLLBACK IMMEDIATE"
    [string]$pwbsql = "ALTER DATABASE $PWBDB SET NEW_BROKER WITH ROLLBACK IMMEDIATE"

    Write-Verbose "Inicializando Serivice Broker para PLS"
    #$PLSDB.parent.ConnectionContext.ExecuteNonQuery($plssql) | Out-Null
    $DBServer.ConnectionContext.ExecuteNonQuery($plssql) | Out-Null
    if ($SkipPWB -eq $false){
        Write-Verbose "Inicializando Serivice Broker para PWB"
        #$PWBDB.parent.ConnectionContext.ExecuteNonQuery($pwbsql) | Out-Null
        $DBServer.ConnectionContext.ExecuteNonQuery($pwbsql) | Out-Null
    }

    $sql = "DELETE FROM $PLSDB.es.ServiceBrokerConversations;"
    
    Write-Verbose "Limpiando tabla es.ServiceBrokerConversations"
    #$PLSDB.parent.ConnectionContext.ExecuteNonQuery($sql) | Out-Null
    $DBServer.ConnectionContext.ExecuteNonQuery($sql) | Out-Null
}
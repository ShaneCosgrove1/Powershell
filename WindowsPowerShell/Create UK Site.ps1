$tenant = "wbcie"
$username = "fintan.crawley@wardandburke.com"
$siteScriptTitle = "UK Job Template"
$siteScriptDescription = ""
$global:siteScriptId = "" 

function addSiteScript($siteScriptTitle, $siteScriptDescription, $script) {
  $siteScripts = Get-SPOSiteScript 
  $siteScriptObj = $siteScripts | Where-Object {$_.Title -eq $siteScriptTitle} 
  if ($siteScriptObj) {
    $confirmation = Read-Host "There is an existing site script with the same name. Update that?"  
    if ($confirmation -eq 'y') {
      Set-SPOSiteScript -Identity $siteScriptObj.Id -Content $script
      $global:siteScriptId= $siteScriptObj.Id
    }
  }
  else {
    $siteScriptObj = Add-SPOSiteScript -Title $siteScriptTitle -Description $siteScriptDescription -Content $script
    $global:siteScriptId= $siteScriptObj.Id
  }
}
$script = @'
{
  "$schema": "schema.json",
  "actions": [
    {
      "verb": "joinHubSite",
      "hubSiteId": "b2e0b8f0-5a9c-4d41-835f-bb154478ffbd"
    },
    {
      "verb": "setSiteExternalSharingCapability",
      "capability": "Disabled"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-IT",
      "group": "Owners"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-Directors",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-EU-Admin",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-EU-Accounts",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-EU-Estimating",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-UK-SHEQ",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-UK-AllJobs",
      "group": "Members"
    },
    {
      "verb": "addPrincipalToSPGroup",
      "principal": "Security-UK-Design",
      "group": "Members"
    },
    {
        "verb": "triggerFlow",
        "url": "https://prod-52.westeurope.logic.azure.com:443/workflows/c7e2b5d08d3a498c9ae7dda233155e6f/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=t6jD71UQ5PtRvS5lEeRWGWQHBdgQusWNX3VYWV0gI38",
        "name": "Record site creation event",
        "parameters": {
            "event":"site creation",
            "product":"SharePoint Online"
        }
    }
  ],
  "bindata": {},
  "version": 1
}
'@
Connect-SPOService -Url https://wbcie-admin.sharepoint.com -Credential $username
addSiteScript $siteScriptTitle $siteScriptDescription $script

function addToSiteDesign($siteDesignTitle) {
  $siteScripts = Get-SPOSiteScript 
  $siteScriptObj = $siteScripts | Where-Object {$_.Title -eq $siteScriptTitle} 
  if($siteScriptObj) {
    $siteDesigns = Get-SPOSiteDesign
    $siteDesignsLength = @($siteDesigns).length
    if($siteDesignsLength -gt 1) {
      $siteDesign = $siteDesigns | Where-Object($_.Title -eq $siteDesignTitle)
    } elseIf($siteDesignsLength -eq 1){
      if($siteDesigns.Title -eq $siteDesignTitle) {
        $siteDesign = $siteDesigns
      }
    }
    $siteScriptIds = $siteDesign.SiteScriptIds
    if (!($siteDesign.SiteScriptIds -match $siteScriptObj.Id)){
      $siteScriptIds += $siteScriptObj.Id
      Set-SPOSiteDesign -Identity $siteDesign.Id -SiteScripts $siteScriptIds
    }
  } else {
    "No Site Design found with a title " + $siteDesignTitle
  }
}

function addToNewSiteDesign($siteDesignTitle,$siteDesignWebTemplate, $siteScriptId) {
  if($siteScriptId -ne "") {
    Add-SPOSiteDesign -Title $siteDesignTitle -WebTemplate $siteDesignWebTemplate -SiteScripts $siteScriptId
  }
}
addToNewSiteDesign "UK Job Template" 64 $global:siteScriptId
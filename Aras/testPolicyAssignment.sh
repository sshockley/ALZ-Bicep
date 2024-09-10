#!/bin/sh

# --- Aras values
# May need to to az bicep install
source Aras/.env-${ENVIRONMENT}
tags="{\"businessimpact\": \"low\", \"classification\": \"confidential\", \"costcenter\": \"700\", \"createdBy\": \"${CONTACT}\", \"customername\": \"Aras\", \"environment_type\": \"${ENVIRONMENT_TYPE}\", \"function\": \"security\", \"owner\": \"${CONTACT}\", \"projectname\": \"aras-core\"}"

#parPolicyAssignmentParameters="{\"emailSecurityContact\":\"${CONTACT}\",\"logAnalytics\":\"la-${APPNAME}-${ENVIRONMENT_TYPE}-${REGION}\",\"ascExportResourceGroupName\":\"rg-${APPNAME}-${ENVIRONMENT_TYPE}\",\"ascExportResourceGroupLocation\":\"${REGION}\",\"enableAscForServers\":\"Enabled\",\"enableAscForSql\":\"Enabled\"}"
parPolicyAssignmentParameters="{\"emailSecurityContact\":{\"value\":\"${CONTACT}\"},"
parPolicyAssignmentParameters+="\"logAnalytics\":{\"value\":\"la-${APPNAME}-${ENVIRONMENT_TYPE}-${REGION}\"},"
parPolicyAssignmentParameters+="\"ascExportResourceGroupName\":{\"value\":\"rg-${APPNAME}-${ENVIRONMENT_TYPE}\"},"
parPolicyAssignmentParameters+="\"ascExportResourceGroupLocation\":{\"value\":\"${REGION}\"},"
parPolicyAssignmentParameters+="\"enableAscForServers\":{\"value\":\"Enabled\"},"
parPolicyAssignmentParameters+="\"enableAscForSql\":{\"value\":\"Enabled\"}}"

parTopLevelPolicyAssignmentSovereigntyGlobal="{"
parTopLevelPolicyAssignmentSovereigntyGlobal+="\"parTopLevelSovereigntyGlobalPoliciesEnable\":{\"value\":false}"
parTopLevelPolicyAssignmentSovereigntyGlobal+="\"parListOfAllowedLocations\":{\"value\":\"[]\"}"
parTopLevelPolicyAssignmentSovereigntyGlobal+="\"parPolicyEffect\":{\"value\":\"Deny\"}"
parTopLevelPolicyAssignmentSovereigntyGlobal+="}"

parPolicyAssignmentSovereigntyConfidential="{"
parPolicyAssignmentSovereigntyConfidential+="\"parAllowedResourceTypes\":{\"value\":false}"
parPolicyAssignmentSovereigntyConfidential+="\"parListOfAllowedLocations\":{\"value\":\"[]\"}"
parPolicyAssignmentSovereigntyConfidential+="\"parAllowedVirtualMachineSKUs\":{\"value\":\"[]\"}"
parPolicyAssignmentSovereigntyConfidential+="\"parPolicyEffect\":{\"value\":\"Deny\"}"
parPolicyAssignmentSovereigntyConfidential+="}"


# ---

# For Azure Global regions
# Set Platform management subscription ID as the the current subscription
#ManagementSubscriptionId="fac42140-00cf-4c3a-94ca-f672e175c441"
#az account set --subscription $ManagementSubscriptionId

# For Azure GCC-H regions

dateYMD=$(date +%Y%m%dT%H%M%S%NZ)
NAME="alz-PolicyDineAssignments-${dateYMD}"
#MGID="alz-landingzones"
MGID="TMP-MGT-GRP"
#TEMPLATEFILE="infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep"
TEMPLATEFILE="infra-as-code/bicep/modules/policy/assignments/alzDefaults/mg-alzDefaultPolicyAssignments.bicep"
#PARAMETERS="@infra-as-code/bicep/modules/policy/assignments/parameters/mg-policyAssignmentManagementGroup.dine.parameters.all.json"
PARAMETERS="infra-as-code/bicep/modules/policy/assignments/alzDefaults/parameters/alzDefaultPolicyAssignments.parameters.all.json"

# POLICIES=$(grep 'name: ' infra-as-code/bicep/modules/policy/definitions/mg-customPolicyDefinitions.bicep | \
#   cut -d':' -f2 | \
#   grep " '" | \
#   head -n -1 | \
#   tr -d " '")

POLICIES="DenyAction-DeleteProtection"

for policy in $POLICIES; do
  echo "Doing ${policy}"

  parPolicyAssignmentDefinitionId="/providers/Microsoft.Management/managementGroups/${MGID}/providers/Microsoft.Authorization/policySetDefinitions/${policy}"

  az deployment mg validate \
    --name ${NAME} \
    --location ${REGION} \
    --management-group-id ${MGID} \
    --template-file ${TEMPLATEFILE} \
    --parameters parTopLevelManagementGroupPrefix="alz" \
        parTopLevelManagementGroupSuffix="" \
        parLogAnalyticsWorkSpaceAndAutomationAccountLocation=${REGION} \
        parLogAnalyticsWorkspaceLogRetentionInDays="365" \
        parAutomationAccountName="alz-AutomationAccount" \
        parMsDefenderForCloudEmailSecurityContact="sshockley@aras.com" \
        parDisableAlzDefaultPolicies=false \
        parLogAnalyticsWorkspaceResourceID="/subscriptions/a5e9fd1e-d16c-4dac-940c-a9d8b2215175/resourceGroups/rg-Sentinel-prod/providers/Microsoft.OperationalInsights/workspaces/la-Sentinel-prod-usgovvirginia" \
        parTelemetryOptOut=true \
    --debug

"/subscriptions/a5e9fd1e-d16c-4dac-940c-a9d8b2215175/resourceGroups/rg-Sentinel-prod/providers/Microsoft.OperationalInsights/workspaces/la-Sentinel-prod-usgovvirginia"
"/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/alz-logging/providers/Microsoft.OperationalInsights/workspaces/alz-log-analytics"
        # Supported in gov but not used
        #parDdosProtectionPlanId \


        # Not supported in Gov
#        parDdosEnabled=false \
#        parPlatformMgAlzDefaultsEnable=true \
#        parLandingZoneChildrenMgAlzDefaultsEnable=true \
#        parLandingZoneMgConfidentialEnable=true \

        # parDataCollectionRuleVMInsightsResourceId="/subscriptions/a5e9fd1e-d16c-4dac-940c-a9d8b2215175/resourceGroups/rg-Sentinel-prod/providers/Microsoft.Insights/dataCollectionRules/dcr-Sentinel-prod-usgovvirginia" \
        # parDataCollectionRuleChangeTrackingResourceId="/subscriptions/a5e9fd1e-d16c-4dac-940c-a9d8b2215175/resourceGroups/rg-Sentinel-prod/providers/Microsoft.Insights/dataCollectionRules/dcr-Sentinel-prod-usgovvirginia" \
        # parDataCollectionRuleMDFCSQLResourceId= \
        # parUserAssignedManagedIdentityResourceId= \
        # parPrivateDnsResourceGroupId \
        # parPrivateDnsZonesNamesToAuditInCorp \
        # parVmBackupExclusionTagName="" \
        # parVmBackupExclusionTagValue="" \
        # parExcludedPolicyAssignments="" \
        # parTopLevelPolicyAssignmentSovereigntyGlobal=${parTopLevelPolicyAssignmentSovereigntyGlobal} \
        # parPolicyAssignmentSovereigntyConfidential=${parPolicyAssignmentSovereigntyConfidential}


    # --parameters ${PARAMETERS} \
    # --parameters parPolicyAssignmentParameters=${parPolicyAssignmentParameters} \
    # --parameters parPolicyAssignmentIdentityRoleAssignmentsAdditionalMgs="[]" \
    # --parameters parPolicyAssignmentDefinitionId=${parPolicyAssignmentDefinitionId}
done


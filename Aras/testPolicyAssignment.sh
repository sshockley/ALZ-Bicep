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

parPolicyAssignmentDefinitionId="/providers/Microsoft.Management/managementGroups/${MANAGEMENTGROUP}/providers/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config"

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
TEMPLATEFILE="infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep"
PARAMETERS="@infra-as-code/bicep/modules/policy/assignments/parameters/policyAssignmentManagementGroup.dine.parameters.all.json"

#echo ${parPolicyAssignmentParameters}

az deployment mg create \
  --name ${NAME} \
  --location ${REGION} \
  --management-group-id ${MGID} \
  --template-file ${TEMPLATEFILE} \
  --parameters ${PARAMETERS} \
  --parameters parPolicyAssignmentParameters=${parPolicyAssignmentParameters} \
  --parameters parPolicyAssignmentIdentityRoleAssignmentsAdditionalMgs="[]" \
  --parameters parPolicyAssignmentDefinitionId=${parPolicyAssignmentDefinitionId}

#parTags="${tags}"

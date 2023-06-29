/* Description : This class handles the creation of a Case and updates fields based on the request payload. 
                It also performs validation, generates comments, and provides error and success responses.
* @Author : Sweta Kumari
*/
@RestResource(urlMapping='/TaskOnCase/')
global with sharing class TaskOnCase 
{
    public static List<String> errorAndSuccessValueInList = new List<String>();
    public static RestResponse response;
    public static String caseId;
    public static String onlinseSource;
    public static boolean isCreateCase = false;
    @HttpPost
    global static void createCaseAndUpdateField()
    {
        try 
        {
            RestRequest restRequest = RestContext.request;
            // Deserialize the request body into a map
            Map<String,Object> requestBodyInMap = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            response = RestContext.response;
            caseId = (String)requestBodyInMap.get('caseid');
            onlinseSource = (String)requestBodyInMap.get('tlsonlinesource');
            // Define matching fields, record type, and contact reason
            Map<String,String> matchingField = GenericConstant.MATCHINGFIELD;
            String recordTypeName = GenericConstant.ORDERREMEDIATION;
            String genericRecordTypeName = GenericConstant.GENERALRECORDTYPE;
            String contactReason = 'Query or Manage My Order';
            // Build the SOQL query to retrieve Case records
            String query = 'SELECT Id, RecordTypeId, Status, IsClosed, TLS_DocumentationLink__c, TLS_URL__c, TLS_OnlineSource__c, ParentId, CaseNumber, UI_Contact_Reason__c, CaseNumber__c ';
            String fieldsToQuery = String.join(matchingField.values(), ',');
            query += ', ' + fieldsToQuery;
            query += ' FROM Case ';
            query += 'WHERE (RecordType.Name = \'' + recordTypeName + '\' OR (RecordType.Name = \'' + genericRecordTypeName + '\' AND UI_Contact_Reason__c = \'' + contactReason + '\'))';
            query += ' AND CaseNumber = \'' + caseId + '\'';
            // Execute the query and store the results in a list
            List<Case> caseValuesInList = (List<Case>) Database.query(query);
            String commentBody = ''; 
            Case caseNewObject = new Case();
            String caseNumber;
            // Validate the payload
            if(payLoadValidation(requestBodyInMap,response))
            {
                if(!caseValuesInList.isEmpty())
                {   
                    String openCase = string.format(GenericConstant.OPENCLOSE_CASE_COMMENT, new List<String>{String.valueOf(requestBodyInMap.get('tlsdocumentationlink'))}) + GenericConstant.OPEN_CASE_COMMENT;
                    String closedCase = string.format(GenericConstant.OPENCLOSE_CASE_COMMENT, new List<String>{String.valueOf(requestBodyInMap.get('tlsdocumentationlink'))}) + GenericConstant.CLOSED_CASE_COMMENTS;
                    // Determine the comment body based on whether the case is closed or open
                    commentBody = caseValuesInList[0].IsClosed ? closedCase : openCase ;
                    // Check if the matching fields match the values in the request payload
                    if((matchingFieldCondition(requestBodyInMap,caseValuesInList[0],matchingField)))
                    {
                        if(!caseValuesInList[0].IsClosed)
                        {
                            // Update the TLS_DocumentationLink__c field of the Case object
                            UPDATE caseValuesInList[0];
                            // Call the genericCaseComment method, passing the Case ID and commentBody
                            genericCaseComment(caseValuesInList[0].Id, commentBody);
                            errorAndSuccessValueInList.add(caseValuesInList[0].Id);
                            errorAndSuccessValueInList.add(caseValuesInList[0].CaseNumber);
                            // Call the errorAndSuccessResponse method, passing the errorAndSuccessValueInList and response
                            errorAndSuccessResponse(errorAndSuccessValueInList , response); 
                        }
                        else  
                        {
                            // Call the genericCaseComment method, passing the Case ID and commentBody
                            genericCaseComment(caseNewObject.Id,commentBody);
                            // Call the errorAndSuccessResponse method, passing the errorAndSuccessValueInList and response
                            errorAndSuccessResponse(errorAndSuccessValueInList , response); 
                        }
                    }
                    else 
                    {
                    isCreateCase = true;
                    }
                }
                else 
                {
                    isCreateCase = true;
                }
                if(isCreateCase)
                {
                    String comments = String.format(GenericConstant.OPENCLOSE_CASE_COMMENT, new List<String>()) + GenericConstant.OPEN_CASE_COMMENT;
                    if (GenericConstant.ONLINESOURCEFIELDVALUECHECK.get(onlinseSource) )
                    {
                        createNewCase(requestBodyInMap , caseNewObject , caseNumber);
                        genericCaseComment(caseNewObject.Id,comments);
                        errorAndSuccessResponse(errorAndSuccessValueInList , response); 
                    }
                    else
                    {
                        String errorMessage = 'Invalid field value put correct value i-e'+GenericConstant.ONLINESOURCEFIELDVALUECHECK.keySet() ;
                        // Generate an error response with the error message
                        System.JSONGenerator formattedJsonData = JsonGenerator.resultOfErrorResponseData('400',errorMessage);
                        String jsonString = formattedJsonData.getAsString(); 
                        response.responseBody = Blob.valueOf(jsonString); 
                    }
                }
            }
        }
        catch (Exception e) 
        {
            System.debug('exception'+e.getMessage());
        }
    }     
    
    public static Boolean payLoadValidation(Map<String,Object> requestBody, RestResponse res)
    {
        Boolean manadatoryFieldCondition = false;
        List<String> missingMadatoryFieldList = new List<String>();
        String errorMsg = 'Field(s) [';
        // Iterate over each mandatory field defined in GenericConstant.MANADATORYFIELD
        for (String manadatoryField  : GenericConstant.MANADATORYFIELD) 
        {
            // Check if the request body contains the mandatory field, and if its value is blank or "null"
            if(!requestBody.containsKey(manadatoryField) || String.isBlank((String)requestBody.get(manadatoryField)) ||
            String.valueOf(requestBody.get(manadatoryField)).equalsIgnoreCase('null'))
            {
                missingMadatoryFieldList.add(manadatoryField);
            }
        }

        if(missingMadatoryFieldList.isEmpty())
        {
            // If there are no missing mandatory fields, set the mandatoryFieldCondition to true
            manadatoryFieldCondition = true;
        }
        else
        {
            // If there are missing mandatory fields, construct an error message
            errorMsg += String.join(missingMadatoryFieldList, ', ') + ']invalid or can not be empty';
            System.JSONGenerator formattedJsonData = JsonGenerator.resultOfErrorResponseData('400',errorMsg);
            String jsonString = formattedJsonData.getAsString(); 
            res.responseBody = Blob.valueOf(jsonString); 
        }
        return manadatoryFieldCondition;
    }
    // To Create a new CaseComment object
    public static void genericCaseComment(String caseID, String comments )
    {
        caseComment caseCommentObject = new CaseComment();
        caseCommentObject.ParentId = caseID;
        caseCommentObject.IsPublished = true;
        if(String.isNotBlank(comments))
        {
           caseCommentObject.CommentBody = comments;
        }
        INSERT caseCommentObject;
        
    }
    // To Create new case
    public static void createNewCase(Map<String,Object> requestData, Case caseNewObject , String caseNumber)
    {
        caseNewObject.RecordTypeId = GenericConstant.GENERALRECORDTYPEID;
        caseNewObject.Status = GenericConstant.CASESTATUS;
        caseNewObject.Priority = GenericConstant.CASEPPRIORITY;
        caseNewObject.UI_Contact_Reason__c = GenericConstant.CASECONTACTREASON;
        caseNewObject.TLS_DocumentationLink__c = (String)requestData.get('tlsdocumentationlink');
        caseNewObject.TLS_OnlineSource__c = (String)requestData.get('tlsonlinesource');
        caseNewObject.TLS_URL__c = (String)requestData.get('tlsurl');
        caseNewObject.Origin = (String)requestData.get('origin');
        INSERT caseNewObject;
        // Retrieve the CaseNumber for the inserted case
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseNewObject.Id];
        caseNumber = insertedCase.CaseNumber;
        errorAndSuccessValueInList.add(caseNewObject.Id);
        errorAndSuccessValueInList.add(caseNumber);
        // Set the Description field for the new case with the case number and additional comments
        caseNewObject.Description = String.format(GenericConstant.CASEDESCRRIPTION, new List<String>{caseNumber}) + string.format(GenericConstant.OPENCLOSE_CASE_COMMENT, new List<String>{String.valueOf(requestData.get('tlsdocumentationlink'))}) + GenericConstant.OPEN_CASE_COMMENT;
    }
    // TO Generate a success response with the provided errorAndSuccessValueInList
    public static void errorAndSuccessResponse(List<String> errorAndSuccessValueInList , RestResponse res)
    {
        System.JSONGenerator formattedJsonData = JsonGenerator.resultOfSuccessResponseData(errorAndSuccessValueInList);
        String jsonString = formattedJsonData.getAsString(); 
        res.responseBody = Blob.valueOf(jsonString); 
    }
    // To get the matchingFieldCondition flag
    private static Boolean matchingFieldCondition(Map<String,Object> requestData , Case caseObj , Map<String,String> matchingField)
    {
        Boolean matchingFieldCondition = false;
        for(String matchingValues : matchingField.keySet())
        {
            String matchFieldValue = (String)requestData.get(matchingValues);
            System.debug('matchFieldValue'+ matchFieldValue);
            String matchedFieldValue = String.valueOf(caseObj.get((matchingField.get(matchingValues))));
            System.debug('matchedFieldValue'+ matchedFieldValue);
            if(matchFieldValue.equalsIgnoreCase(matchedFieldValue))
            {
                matchingFieldCondition = true;
            }
        }
       return matchingFieldCondition;
    }
}
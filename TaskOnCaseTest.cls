@IsTest
public class TaskOnCaseTest 
{
    @testSetup
    static void test()
    {
        Account acc = new Account();
        acc.Name = 'Postman';
        acc.CustomerId__c = '9990';
        Insert acc;
        Case caseobj = new Case();
        Id recordName =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
        caseobj.Status = 'New';
        caseobj.Origin = 'Online';
        caseobj.AccountId = acc.Id;
        caseobj.UI_Contact_Reason__c = 'Query or Manage My Order';
        Insert caseobj;
    }
    @IsTest
    public static void updateCaseTest() 
    {
        case updateCase= [select Id,CAC_ID__c,Origin,AccountId,UI_Contact_Reason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case WHERE Origin = 'Online' Limit 1];
        String str = '{\"tlsdocumentationlink\": \"closed case Sharepoint Document URL\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://stage.telstra.com.au/dev/alvin-test-page1/web2case112\" ,\"origin\" : \"Online\",\"accountnumber\" : \"'+updateCase.CAC_ID__c+'\", \"caseid\" : \"'+updateCase.CaseNumber+'\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = '/services/apexrest/TaskOnCase/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        TaskOnCase.createCaseAndUpdateField();
        assert.areEqual([SELECT ID,Origin,TLS_DocumentationLink__c FROM Case WHERE Origin = 'Online' ].TLS_DocumentationLink__c, 'closed case Sharepoint Document URL');
        assert.areEqual(200,res.statusCode);
        Test.stopTest();
    }
    @IsTest
    public static void payloadTest() 
    {
        String str = '{\"tlsdocumentatilink\": \"closed case Sharepoint Document URL\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://stage.telstra.com.au/dev/alvin-test-page1/web2case112\" ,\"origin\" : \"Online\",\"accountnumber\" : \"9904\", \"caseid\" : \"123489\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = '/services/apexrest/TaskOnCase/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
       	TaskOnCase.createCaseAndUpdateField();
        assert.areEqual(400,res.statusCode);
        Test.stopTest();
    }
    @IsTest
    public static void createNewCaseTest()
    {
        case newCase= [select Id,CAC_ID__c,Origin,AccountId,UI_Contact_Reason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case Limit 1];
        String str = '{\"tlsdocumentationlink\": \"closed case Sharepoint Document URL\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://stage.telstra.com.au/dev/alvin-test-page1/web2case112\" ,\"origin\" : \"Online\",\"accountnumber\" : \"999\", \"caseid\" : \"090\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = '/services/apexrest/TaskOnCase/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        TaskOnCase.createCaseAndUpdateField();
        assert.areEqual(200,res.statusCode);
        Test.stopTest();
    }
    @IsTest
    public static void onlineSourceWrongDataTest()
    {
        case newCase= [select Id,CAC_ID__c,Origin,AccountId,UI_Contact_Reason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case Limit 1];
        String str = '{\"tlsdocumentationlink\": \"closed case Sharepoint Document URL\",\"tlsonlinesource\" :\"Occupancy\",\"tlsurl\" : \"https://stage.telstra.com.au/dev/alvin-test-page1/web2case112\" ,\"origin\" : \"Online\",\"accountnumber\" : \"999\", \"caseid\" : \"090\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = '/services/apexrest/TaskOnCase/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        TaskOnCase.createCaseAndUpdateField();
        assert.areEqual(400,res.statusCode);
        Test.stopTest();
    }
}
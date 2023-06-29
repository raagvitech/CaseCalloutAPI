public with sharing class JsonGenerator 
{
    public static System.JSONGenerator  resultOfErrorResponseData( String statusCode , String msg) 
    {
       try
        {
            System.JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('status',statusCode);
            jsonGen.writeStringField('success', 'false');
            jsonGen.writeFieldName('Error');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('message',msg);
            jsonGen.writeEndObject();
            jsonGen.writeEndObject();
            return jsonGen;
        }
        catch (Exception ex) 
        {
            System.JSONGenerator errorJsonGen = JSON.createGenerator(true);
            errorJsonGen.writeStartObject();
            errorJsonGen.writeStringField('message', 'An error occurred while generating the JSON response.');
            errorJsonGen.writeStringField('exceptionMessage', ex.getMessage());
            errorJsonGen.writeEndObject();
            return errorJsonGen;
        }
    }
    public static System.JSONGenerator  resultOfSuccessResponseData( List<String> errorAndSuccessValueInList) 
    {
        try
        {
            System.JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('status', '201');
            jsonGen.writeStringField('success', 'true');
            jsonGen.writeStringField('time', String.valueOf(DateTime.now()));
            jsonGen.writeFieldName('data');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('Id', errorAndSuccessValueInList[0]);
            jsonGen.writeStringField('CaseNumber', errorAndSuccessValueInList[1]);
            jsonGen.writeEndObject();
            jsonGen.writeEndObject();
            return jsonGen;
        }
        catch (Exception ex) 
        {
            System.JSONGenerator errorJsonGen = JSON.createGenerator(true);
            errorJsonGen.writeStartObject();
            errorJsonGen.writeStringField('message', 'An error occurred while generating the JSON response.');
            errorJsonGen.writeStringField('exceptionMessage', ex.getMessage());
            errorJsonGen.writeEndObject();
            return errorJsonGen;
        }
    }
}
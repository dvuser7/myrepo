/*
@description: Controller for Popover component
@author: Dimpi Vora
@created: 01/03/2018
*/

public with sharing class PopoverController {
    
    private static String CLASSNAME = 'PopoverController';
    
    //Validates specified fields, attempts to execute SOQL, and return results
    @AuraEnabled
    public static Map<String, List<Object>> getPopoverDetails(String objectName, String recordId, String fieldsToShow, Integer fieldLimit) {
        Map<String, List<Object>> mapToReturn = new Map<String, List<Object>>();
        List<sObject> queryResult = new List<sObject>();
        
        //Remove whitespace & split string up into list
        fieldsToShow = fieldsToShow.deleteWhitespace();
        List<String> fields = fieldsToShow.split(',');
        
        //Ensures that fields to display on popover are valid before querying
        validateFields(fields,objectName,fieldLimit);
        
        //Build SOQL query to execute for the corresponding object
        String queryStr = 'SELECT Id';
        
        for(String f : queryFields){
            queryStr += ', ' + f;
        }
        
        queryStr+= ' FROM ' + objectName + ' WHERE Id =\''+ recordId +'\'';
        
        try {
            queryResult = new List<sObject>(Database.query(queryStr));
            
        } catch(Exception e) {
            ApexLogHandler.apexLog log = new ApexLogHandler.ApexLog(CLASSNAME,'getPopupDetails', 'An error occured while creating and executing the SOQL query', LoggingLevel.ERROR);
            log.saveLogs();
        }
        
        mapToReturn.put('data',queryResult);
        mapToReturn.put('fields', queryFields);
        mapToReturn.put('titles', titles);
        mapToReturn.put('dataType', dataTypeList);
        return mapToReturn;  
    }
    
    //Helper function functions (below) for validateFields()
    public static List<String> titles = new List<String>();
    public static List<String> queryFields = new List<String>();
    public static List<String> dataTypeList = new List<String>();
    
    //Fetches field details like name, label and datatype and ensure that fields to display on popover are valid 
    private static void validateFields(List<String> fieldList, String objectName, Integer fieldLimit) {
        String dataType;
        String label;
        String fieldName;
        Map<String, Schema.SObjectField> objectData = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for (String f: fieldList) {
            f = f.toLowerCase();
            //Checks if lookup field
            if (f.contains('.')) {
                String[] splitField = f.split('\\.');
                if (splitField.size() == 2) {
                    Schema.DescribeFieldResult field = objectData.get(splitField[0]).getDescribe();
                    handleLookupField(field, splitField[1]);
                }
            }
            else{
                if(objectData.containsKey(f)){
                    //Gets the Name, Label, and Data Type for the fields 
                    fieldName = objectData.get(f).getDescribe().getName();
                    dataType = String.valueOf(objectData.get(f).getDescribe().getType());
                    label = objectData.get(f).getDescribe().getLabel();
                    checkIfValuesExist(fieldName, label, dataType);
                }
            }
            
            //If amount of fields in list is greater than or equal to the limit, break out of loop
            if(queryFields.size() >= Integer.valueOf(fieldLimit)){
                break;
            }
        }
    }
    
    //Handles lookup field
    private static void handleLookupField(Schema.DescribeFieldResult field, String fieldName) {
        String relationshipName = field.getRelationshipName();
        List<Schema.SObjectType> refFieldData = field.getReferenceTo();
        String refObject = refFieldData[0].getDescribe().getName();
        Map<String, Schema.SObjectField> lookupData = Schema.getGlobalDescribe().get(refObject).getDescribe().fields.getMap();
        if(lookupData.containsKey(fieldName)) {
            //Gets the Name, Label, and Data Type for the fields 
            String lookupTitle = lookupData.get(fieldName).getDescribe().getLabel();
            String lookupdataType = String.valueOf(lookupData.get(fieldName).getDescribe().getType());            
            String apiName = lookupData.get(fieldName).getDescribe().getName();
            String combo = relationshipName + '.' + apiName;
            checkIfValuesExist(combo, lookupTitle, lookupdataType);
        }
    }
    
    //Checks if values already exist in set
    private static void checkIfValuesExist(String field, String title, String dataType) {
        if(!(new Set<String>(queryFields).contains(field))) {
            queryFields.add(field);
            titles.add(title);
            dataTypeList.add(dataType);
        }
    }
}
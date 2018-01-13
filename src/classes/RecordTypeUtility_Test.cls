/*
    @description: Tests for RecordTypeUtility Class
    @author: Dimpi Vora
    @created: 9/23/2017
*/
@isTest
private class RecordTypeUtility_Test {

	static testMethod void testGetDeveloperNameRecordTypeIds() {
		//RecordTypes can not be created through Apex Code so existing data must be used
		//Get list of objects with multiple recordtypes
		List<SObject> listObjects = [SELECT SobjectType FROM RecordType WHERE IsActive = true GROUP BY SobjectType LIMIT 5];
	        
		Set<String> objectTypes = new Set<String>();

		for(SObject obj : listObjects)
		{
			objectTypes.add(String.valueOf(obj.get('SobjectType')));
		}

		for(RecordType obj : [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType IN :objectTypes])
		{
			//Call function being tested
			Map<String, ID> mapRecordTypes = RecordTypeUtility.getDeveloperNameRecordTypeIds(obj.SobjectType);

			//Check that counts match expected
			system.assertNotEquals(mapRecordTypes.size(), 0, 'Count is expected to not equal 0');
			//Check that DeveloperName is in the returned Map
			system.assert(mapRecordTypes.containsKey(String.valueOf(obj.get('DeveloperName'))), 'Expected Key not found');
		}
		
    }
    
    static testMethod void testGetDeveloperName() {
        //RecordTypes can not be created through Apex Code so existing data must be used
        //Get list of objects with multiple recordtypes
        List<SObject> listObjects = [SELECT SobjectType FROM RecordType WHERE IsActive = true GROUP BY SobjectType LIMIT 5];
        
        Set<String> objectTypes = new Set<String>();

        for(SObject obj : listObjects)
        {
            objectTypes.add(String.valueOf(obj.get('SobjectType')));
        }
        
        for(RecordType obj : [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType IN :objectTypes])
        {
            //Call function being tested
            String devName = RecordTypeUtility.getDeveloperName(String.valueOf(obj.get('SobjectType')), obj.Id);
            //Call it again to hit cache code
            String devNameFromCache = RecordTypeUtility.getDeveloperName(String.valueOf(obj.get('SobjectType')), obj.Id);
            
            //Check that expected DeveloperName was returned
            system.assertEquals(String.valueOf(obj.get('DeveloperName')), devName, 'DeveloperName did not match expected value');
            //Check that cached value also matches
            system.assertEquals(String.valueOf(obj.get('DeveloperName')), devNameFromCache, 'DeveloperName from cache did not match expected value');
            
        }
        
    }
    
	static testMethod void testGetRecordTypeId() {
        //RecordTypes can not be created through Apex Code so existing data must be used
        //Get list of objects with multiple recordtypes
        List<SObject> listObjects = [SELECT SobjectType FROM RecordType WHERE IsActive = true GROUP BY SobjectType LIMIT 5];
        
        Set<String> objectTypes = new Set<String>();

        for(SObject obj : listObjects)
        {
            objectTypes.add(String.valueOf(obj.get('SobjectType')));
        }
        
        for(RecordType obj : [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType IN :objectTypes])
        {
            //Call function being tested
            String recordTypeId = RecordTypeUtility.getRecordTypeId(String.valueOf(obj.get('SobjectType')), String.valueOf(obj.get('DeveloperName')));
            //Call it again to hit cache code
            String recordTypeIdFromCache = RecordTypeUtility.getRecordTypeId(String.valueOf(obj.get('SobjectType')), String.valueOf(obj.get('DeveloperName')));
            
            //Check that expected recordTypeId was returned
            system.assertEquals(obj.Id, recordTypeId, 'recordTypeId did not match expected value');
            //Check that expected recordTypeId was returned from cache as well
            system.assertEquals(obj.Id, recordTypeIdFromCache, 'recordTypeIdFromCache did not match expected value');
        }
        
    }
}
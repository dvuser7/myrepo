/*
    @description: Class that returns the Record Type or Developer Name
    @author: Dimpi Vora
    @created: 9/21/2017
*/
public class RecordTypeUtility {

    private static Map<Id, RecordType> mapCache = new Map<Id, RecordType>();
    
    /*
     @description: returns DeveloperName for the supplied Object and RecordTypeId
     */
    public static String getDeveloperName(String objectName, String recordTypeId) {
        String developerName = '';
        
        //check if id is stored in cached map
        if(mapCache.containsKey(recordTypeId) && mapCache.get(recordTypeId).SobjectType == objectName) {
            system.debug('(cached) DeveloperName = ' + mapCache.get(recordTypeId).DeveloperName + 
                         ' for ' + objectName + ' with Id of ' + recordTypeId);
            return String.valueOf(mapCache.get(recordTypeId).DeveloperName);
        }
        else{
        
        	List<RecordType> recordTypes = Database.query('SELECT Id, DeveloperName, SobjectType ' +
        												'FROM RecordType ' +
        												'WHERE IsActive = true AND SobjectType =: objectName AND Id =: recordTypeId');
        
        	//add results to cache map
        	mapCache.putAll(recordTypes);
        
        	if(!recordTypes.isEmpty()) {
				developerName = recordTypes[0].DeveloperName;
				system.debug('DeveloperName = ' + developerName + ' for ' + objectName + ' with Id of ' + recordTypeId); 
        	}
        	else{
            	system.debug('No active record types for ' + objectName + ' with Id of ' + recordTypeId);
            }
        	
        	return developerName;
        }
    }
    

	/*
     @description: returns RecordTypeId for the supplied Object and DeveloperName
     */
    public static String getRecordTypeId(String objectName, String developerName) {
        Id recordTypeId = null;
        
        //loop through the cached map
        RecordType mapRecord;
        for(Id mapId : mapCache.keySet())
        {
			mapRecord = mapCache.get(mapId);
            //check if record is the desired record
			if(mapRecord.DeveloperName == developerName && mapRecord.SobjectType == objectName){
                recordTypeId = mapRecord.Id;
                //record found exit the for loop
                break;
          	}
        }
        
        if(recordTypeId != null) {
			system.debug('(cached) Id = ' + mapRecord.Id + ' for ' + objectName + ' with DeveloperName of ' + developerName);
            
            return recordTypeId; 
        }
        else{
            List<RecordType> recordTypes = Database.query('SELECT Id, DeveloperName, SobjectType ' +
                										'FROM RecordType ' +
														'WHERE IsActive = true AND SobjectType =: objectName AND DeveloperName =: developerName');
            
            //add results to cache map
            mapCache.putAll(recordTypes);
            
            if(!recordTypes.isEmpty()) { 
                recordTypeId = recordTypes[0].Id;
                system.debug('Id = ' + recordTypeId + ' for ' + objectName + ' with DeveloperName of ' + developerName); 
            }
            else{
            	system.debug('No active record types for ' + objectName + ' with DeveloperName of ' + developerName);
            }
            
            return recordTypeId;
        }
    }

    /*
      @description: returns DeveloperNames for all RecordTypes of supplied Object
     */ 
    public static Map<String, Id> getDeveloperNameRecordTypeIds(String objectName) {
		//not checking cache because no guarantee you have all records from that object
        Map<String, Id> mapRecordTypes = new Map<String, Id>();

        List<RecordType> recordTypes = Database.query('SELECT Id, DeveloperName, SobjectType ' +
													'FROM RecordType ' +
													'WHERE IsActive = true AND SobjectType =: objectName');
        for(RecordType rt : recordTypes) 
        {
            mapRecordTypes.put(rt.DeveloperName, rt.Id);
            
            //add it to cache for other methods to use
            if(!mapcache.containsKey(rt.Id)){
				mapCache.put(rt.Id, rt);
            }
        }
        return mapRecordTypes;
    }

}
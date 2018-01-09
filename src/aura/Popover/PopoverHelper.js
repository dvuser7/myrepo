({
    doInit : function(component, event) {
        this.fetchPopoverFields(component, event);
    },
    
    //Get popover field details 
    fetchPopoverFields: function(component, event){
        var fieldsToShow = component.get("v.fieldsToShow");
        var fieldLimit = component.get("v.fieldLimit");
        var sObjectRowId = component.get("v.sObjectRowId");
        var sObjectAPIName = component.get("v.sObjectAPIName");
        var action = component.get("c.getPopoverDetails");
        action.setParams({ 
            "objectName" : sObjectAPIName,
            "recordId" : sObjectRowId,
            "fieldsToShow" : fieldsToShow,
            "fieldLimit" : fieldLimit
        });
        action.setCallback(this, this.fetchPopoverFields_Callback(component, event));                
        $A.enqueueAction(action);
    },
    
    //Response for getPopoverDetails
    fetchPopoverFields_Callback: function(component, event) {
        
        return (function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != null) {
                    var objToCreate = {"data": result.data, "fields": result.fields, "titles": result.titles, "dataType": result.dataType};
                    this.handleResults(component, objToCreate);
                }     
            }
        });
    },
    
    //Parse the output response to display
    handleResults : function(component, results) {
        var obj = results.data;
        var data = obj[0];
        var fields = results.fields;
        var titles = results.titles;
        var dataType = results.dataType;
        var listOfObjects = [];
        var objData;
        var targetData;
        
        for(var a = 0; a < fields.length; a++) {
            var field = fields[a];
            //Checks if lookup field
            if(field.includes(".")) {
                var splitField = field.split(".");
                var objType = splitField[0];
                var objField = splitField[1];
                if(data.hasOwnProperty(objType)) {
                    if((data[objType]).hasOwnProperty(objField)){
                        objData = data[objType][objField];
                        targetData = data[objType]['Id'];
                    }  else {
                        objData = null;
                        targetData = null;
                    }
                } else {
                    objData = null;
                    targetData = null;
                }
            } else {
                objData = data[field];
                targetData = null;
            }
            listOfObjects.push({"title": titles[a], "value":objData, "dataType":dataType[a], "targetId":targetData});
        }
        
        component.set('v.result', listOfObjects);
    },
    
    //Navigates to record page for passed record
    navigateToRecord : function(component, event) {
        var recordId = component.get("v.sObjectRowId");
        var targetId = event.currentTarget.getAttribute("data-id");
        if(targetId != null && targetId != ""){
            recordId = targetId;
        }
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : recordId
        });
        navEvt.fire();
    },
    
    hidePopover: function(component, event){
        component.set('v.checkFlag', false);
        var evt = component.getEvent("closePopover");
        evt.fire();
    }
})
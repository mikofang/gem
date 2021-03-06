({
	addRowHelper: function(component){
        this.addToObjectArray(component, 'v.rowList', 'v.item');
    },
    amountCheck: function(component){
        component.set('v.checkAmountTotals', true);
    },
    addToObjectArray: function(component, vArray, vObj){
        // Pass the component that contains the fields to the list of data
        // The parent list needs an actual reference to the item, 
		// so that it gets updated as fields are filled in
        var objList = component.get(vArray);
        var obj = component.get(vObj);

        objList.push(obj);
        component.set(vArray, objList);
    },
    validateRow: function(component, helper) {
        // Check if this row has all required inputs filled in
        // If none are filled in, assume this row should not be processed
        component.set('v.showError', false);
        
        // Small JS object to store info about current validation check
        var validationInfo = {needsError: [], allBlank: true, validSoFar: true, 
            noDuplicateValueList: []};
        validationInfo.noDuplicateValueList = 
            helper.proxyToObj(component.get('v.noDuplicateValueList'));
        var validForm = true;
        var duplicateCheck = true;
        
        // Show error messages if required fields are blank
        var reqFields = component.find('requiredField');
        reqFields = this.singleInputToArray(reqFields);

        // Add inputs that are set to required but don't have the correct aura:id
        var inputs = this.getInputs(component);
        for(var i in inputs){
            var field = inputs[i];
            var isRequired = field.get('v.required');
            if(isRequired){
                reqFields.push(field);
            }
        }

        // The aura:id of 'noDuplicates' is used to prevent duplicate values across rows
        var noDuplicatesList = component.find('noDuplicates');
        
        if(!reqFields && !noDuplicatesList){
            return true;
        }

        noDuplicatesList = this.singleInputToArray(noDuplicatesList);
        
        // Check required fields
        if(reqFields){
            validForm = reqFields.reduce(function (validSoFar, inputCmp) {
                validationInfo.validSoFar = validSoFar;
                return helper.validateField(component, inputCmp, validationInfo, false, helper);
            }, true);
        }

        if(noDuplicatesList){
            duplicateCheck = noDuplicatesList.reduce(function (validSoFar, inputCmp) {
                validationInfo.validSoFar = validSoFar;
                return helper.validateField(component, inputCmp, validationInfo, true, helper);
            }, true);
        }

        component.set('v.noDuplicateValueList', validationInfo.noDuplicateValueList);

        // If ALL fields are blank, skip this row and consider it valid
        if(validationInfo.allBlank){
            for(var i=0; i<validationInfo.needsError.length; i++){
                helper.removeError(validationInfo.needsError[i]);
            }
            return undefined; // This is interpreted as a blank row
        }

        return validForm && duplicateCheck;
    },
    getInputs: function(component){
        var inputs = [];
        var wrapper = component.find('rowWrapper');
        if(wrapper){
            inputs = wrapper.find({ instancesOf : 'lightning:input' });
        }
        return inputs;
    },
    singleInputToArray: function(findResult){
        // Convert a single input to an array for use in reduce functions
        if(findResult && !findResult.length){
            findResult = [findResult];
        }
        return findResult;
    },
    validateField: function(component, inputCmp, validationInfo, checkDupes, helper){
        var fieldVal = inputCmp.get('v.value');
        var isValid = (fieldVal || fieldVal === false) && fieldVal !== '0';
        
        if(checkDupes){
            // Check for duplicate values
            if(isValid && validationInfo.noDuplicateValueList.indexOf(fieldVal) > -1){
                component.set('v.showError', true);
                component.set('v.errorMessage', $A.get('$Label.c.Error_Duplicate_Value'));
                isValid = false;
                // This value duplicates another field, prevent it
            } else {
                // No duplicate found, add this value to the array to track
                validationInfo.noDuplicateValueList.push(fieldVal);
            }
        }

        // Show error for invalid fields
        if(!isValid){
            helper.addError(inputCmp);
            validationInfo.needsError.push(inputCmp);
        } else {
            // There is at least one field filled in, they are not all blank
            validationInfo.allBlank = false;
            helper.removeError(inputCmp);
        }

        return isValid && validationInfo.validSoFar;
    },
    getRowAmt: function(component){
        var amtField = component.get('v.amtField');
        var item = this.proxyToObj(component.get('v.item'));
        var rowAmt = null;
		if(item && amtField && item[amtField]){
			rowAmt = item[amtField];
        }
        return rowAmt;
    },
    addError: function(inputCmp){
        $A.util.addClass(inputCmp, 'slds-has-error');
    },
    removeError: function(inputCmp){
        $A.util.removeClass(inputCmp, 'slds-has-error');
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})
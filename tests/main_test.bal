import ballerina/log;
import ballerina/test;


@test:Config    
function testGetStudentDetails(){
    log:printDebug("Successfully retrieved students' details");
    boolean result = printStudentDetailsFromGSheet();
    test:assertTrue(result, msg = "Retrieving students' details failed!");
}

//@test:Config    
//function testSetCellDetails(){
//    log:printDebug("Successfully updated the cell detail");
//    boolean result = sendNotification();
//    test:assertTrue(result, msg = "Updating cell detail failed!");
//}

//@test:Config    
//function testSetStudentDetails(){
//    log:printDebug("Successfully updated new student's details");
//    boolean result = sendNotification();
//    test:assertTrue(result, msg = "Updating student's details failed!");
//}

@test:Config    
function testSendNotification(){
    log:printDebug("Sending notification to students");
    boolean result = sendNotification();
    test:assertTrue(result, msg = "Sending notification to students failed!");
}

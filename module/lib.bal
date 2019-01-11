import wso2/gmail;
import wso2/gsheets4;
import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/config;

gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: "",
            clientId: "",
            clientSecret: "",
            refreshToken: ""
        }
    }
};

gsheets4:SpreadsheetConfiguration spreadsheetConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: "",
            clientId: "",
            clientSecret: "",
            refreshToken: ""
        }
    }
};

gsheets4:Client spreadsheetClient = new(spreadsheetConfig);
gmail:Client gmailClient = new(gmailConfig);

public function getStudentDetailsFromGSheet() returns string[][]|error {
    //Read all the values from the sheet
    string[][] values = check spreadsheetClient->getSheetValues("sheetID", "sheetName");
    log:printInfo("Retrieved student details from spreadsheet id: " + "sheetID" + " ; sheet name: " + "sheetName");    //Replace sheetID, sheetName with your sheet id and name
    return values;
}

public function printStudentDetailsFromGSheet() returns boolean{
    var studentDetails = getStudentDetailsFromGSheet();
    if (studentDetails is error) {
        log:printError("Failed to retrieve student details from GSheet", err = studentDetails);
        return false;
    } else {
        int i = 0;
        boolean isSuccess = false;
        foreach var value in studentDetails {
            string studentName = value[0];
            string course = value[1];
            string studentMarks = value[2];
            string studentEmail = value[3];
            io:println(i+1 + "\t" + studentName + "\t" + course + "\t" + studentMarks + "\t" + studentEmail);
            i += 1;
        }
        return isSuccess;
    }
}

public function setCellDetailsInGSheet(string column, int row, string data){
    var cellData = spreadsheetClient->setCellData("sheetID", "sheetName", column, row, data);    //Replace sheetID, sheetName with your sheet id and name
    io:println("Successfully updated cell data \n");
}

public function setStudentDetailsInGSheet(string cell_start, string cell_end, string name, string subject, int marks, string email){
    string [][] data = [[name, subject, string.convert(marks), email]];
    var setData = spreadsheetClient->setSheetValues("sheetID", "sheetName", topLeftCell = cell_start, bottomRightCell = cell_end, data);        //Replace sheetID, sheetName with your sheet id and name
    io:println("Successfully added student's details \n ");
}


public function sendMail(string studentEmail, string name, string subject, string marks)returns boolean{
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = studentEmail;
    messageRequest.sender = "yours@gmail.com";        //Include your emailID inside quotation marks
    messageRequest.subject = subject;
    messageRequest.messageBody = "Hi " + name + "," + "\n" + "Your examination mark is " + marks;
    messageRequest.contentType = gmail:TEXT_HTML;

    var sendMessageResponse = gmailClient->sendMessage("yours@gmail.com", untaint messageRequest);  //Include your emailID inside quotation marks
    string messageId;
    string threadId;
    if (sendMessageResponse is (string, string)){
        (messageId, threadId) = sendMessageResponse;
        log:printInfo("Sent email to " + studentEmail + "with message Id: " + messageId + "thread id: " + threadId);
        return true;
    }else {
        log:printInfo(<string>sendMessageResponse.detail().message);
        return false;
    }
}

public function sendNotification() returns boolean {
    //Retrieve the students details from spreadsheet.
    var studentDetails = getStudentDetailsFromGSheet();
    if (studentDetails is error) {
        log:printError("Failed to retrieve student details from GSheet", err = studentDetails);
        return false;
    } else {
        int i = 0;
        boolean isSuccess = false;
        foreach var value in studentDetails {
            //Skip the first row as it contains header values.
            if (i > 0) {
                string studentName = value[0];
                string course = value[1];
                string studentMarks = value[2];
                string studentEmail = value[3];
                string subject = "Your marks for " + course;
                isSuccess = sendMail(studentEmail, studentName, subject, studentMarks);
                if (!isSuccess) {
                    break;
                }
            }
            i += 1;
        }
        io:println("Successfully sent emails \n");
        return isSuccess;
    }
}

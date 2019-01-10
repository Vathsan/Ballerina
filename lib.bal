import wso2/gmail;
import wso2/gsheets4;
import ballerina/http;
import ballerina/log;
import ballerina/io;

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


function getStudentDetailsFromGSheet() returns string[][]|error {
    //Read all the values from the sheet. Replace Spread_Sheet_ID, Spread_Sheet_Name with your spreadsheet's id, name
    string[][] values = check spreadsheetClient->getSheetValues("Spread_Sheet_ID", "Spread_Sheet_Name");
    log:printInfo("Retrieved student details from spreadsheet id: " + "Spread_Sheet_ID" + " ; sheet name: "
            + "Spread_Sheet_Name");
   return values;
}

function printStudentDetailsFromGSheet() returns boolean{
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

function setCellDetailsInGSheet(string column, int row, string data) returns boolean{
    boolean isSuccess = false;
    var cellData = spreadsheetClient->setCellData("Spread_Sheet_ID", "Spread_Sheet_Name", column, row, data); //Use your spreadsheet's id, name
    isSuccess = true;
    return isSuccess;
}
function setStudentDetailsInGSheet(string cell_start, string cell_end, string name, string subject, int marks, string email) returns boolean{
    boolean isSuccess = false;
    string [][] data = [[name, subject, string.convert(marks), email]];
    var setData = spreadsheetClient->setSheetValues("Spread_Sheet_ID", "Spread_Sheet_Name", topLeftCell = cell_start, bottomRightCell = cell_end, data); //Use your spreadsheet's id, name
    isSuccess = true;
    return isSuccess;
}


function sendMail(string studentEmail, string name, string subject, string marks)returns boolean{
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = studentEmail;
    messageRequest.sender = "";         //Include sender's email
    messageRequest.subject = subject;
    messageRequest.messageBody = "Hi " + name + "," + "\n" + "Your examination mark is " + marks;
    messageRequest.contentType = gmail:TEXT_HTML;

    var sendMessageResponse = gmailClient->sendMessage("sender's email", untaint messageRequest); //type in sender's email
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

function sendNotification() returns boolean {
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
        return isSuccess;
    }
}



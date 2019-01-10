import ballerina/io;

public function main() {

    int operation = 0;
    while (operation != 5) {
        // print options menu to choose from
        io:println("Select operation.");
        io:println("1. View Student Details");
        io:println("2. Update a Cell Value");
        io:println("3. Add New Student");
        io:println("4. Send Email");
        io:println("5. Exit");

        // read user's choice
        string val = io:readln("Enter choice 1 - 5: ");
        var choice = int.convert(val);
        if (choice is int) {
            operation = choice;
        } else {
            io:println("Invalid choice \n");
            continue;
        }

        if (operation == 5) {
            break;
        } else if (operation < 1 || operation > 5) {
            io:println("Invalid choice \n");
            continue;
        }

        // Execute spreadSheet operations based on user's choice
        if (operation == 1) {
            var op = printStudentDetailsFromGSheet();
        } else if (operation == 2) {
            string column = io:readln("Enter column choice A - D: ");
            string srow = io:readln("Enter row: ");
            var row = int.convert(srow);
            int rowNumber = 0;
            if (row is int) {
                rowNumber = row;
            } else {
                io:println("Invalid row number \n");
            continue;
            }
            string data = io:readln("Enter cell data: ");
            var op = setCellDetailsInGSheet(column, rowNumber, data);
        } else if(operation == 3) {
            int row_num = 0;
            var details = getStudentDetailsFromGSheet();
            if (details is error) {
                log:printError("Failed to retrieve student details from GSheet", err = details);
            } else {
                row_num = details.length();
            }
            io:println(row_num);
            string name = io:readln("Enter name: ");
            string subject = io:readln("Enter subject: ");
            string smarks = io:readln("Enter marks: ");
            string email = io:readln("Enter email: ");
            var marks = int.convert(smarks);
            int m = 0;
            if(marks is int){
                m = marks;
            }
            var op = setStudentDetailsInGSheet("A"+string.convert(row_num+1), "D"+string.convert(row_num+1), name, subject, m, email);
            //if(op is true) {io:println("Student details added successfully");}
        } else if(operation == 4){
            var noti = sendNotification();
            //if(noti is true){io:println("Notification send successfully");}
        } else {
            io:println("Invalid choice");
        }
    }
}

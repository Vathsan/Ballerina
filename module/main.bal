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
            var op = printStudentDetailsFromGSheet();
            string column = "";
            string col = "";
            boolean run1 = true;
            while(run1) {
                column = io:readln("Enter column choice A - D: ");
                if (column == "A" || column == "a" || column == "B" || column == "b" || column == "C" || column == "c"
                    || column == "D" || column == "d") {
                    col = column;
                    run1 = false;
                } else {
                    io:println("Invalid column letter \n");
                    continue;
                }
            }
            int row_num = 0;
            var details = getStudentDetailsFromGSheet();
            if (details is error) {
                log:printError("Failed to retrieve student details from GSheet", err = details);
            } else {
                row_num = details.length();
            }
            boolean run2 = true;
            int finalRowNumber;
            int rowNumber = 0;
            while (run2){
                string srow = io:readln("Enter row: ");
                var row = int.convert(srow);
                if (row is int) {
                    rowNumber = row;
                }else {
                    io:println("Invalid row number \n");
                    continue;
                }

                if((rowNumber > 1) && (rowNumber <= (row_num))){
                    finalRowNumber = rowNumber;
                    run2 = false;
                }else {
                    io:println("Row does not exist \n");
                    continue;
                }
            }
            boolean run3 = true;
            while(run3) {
                string data = io:readln("Enter cell data: ");
                if ((col.equalsIgnoreCase("C"))) {
                    var marks = int.convert(data);
                    if (marks is int) {
                        var op1 = setCellDetailsInGSheet(column, rowNumber, string.convert(marks));
                        run3 = false;
                    } else {
                        io:println("Invalid cell input. Enter a number");
                        continue;
                    }
                } else if (col.equalsIgnoreCase("D")) {
                    if(data.contains("@")){
                        var op2 = setCellDetailsInGSheet(column, rowNumber, data);
                        run3 = false;
                    } else {
                        io:println("Invalid emaid id");
                        continue;
                    }

                } else {
                    var op3 = setCellDetailsInGSheet(column, rowNumber, data);
                    run3 = false;
                }
            }
        } else if(operation == 3) {
            int row_num = 0;
            var details = getStudentDetailsFromGSheet();
            if (details is error) {
                log:printError("Failed to retrieve student details from GSheet", err = details);
            } else {
                row_num = details.length();
            }

            string name = io:readln("Enter name: ");
            string subject = io:readln("Enter subject: ");

            boolean run1 = true;
            int m = 0;
            while(run1){
                string smarks = io:readln("Enter marks: ");
                var marks = int.convert(smarks);
                if(marks is int){
                    m = marks;
                    run1 = false;
                } else {
                    io:println("Invalid marks. Enter a number");
                    continue;
                }
            }

            string email = "";
            boolean run2 = true;
            while(run2){
                string emailIn = io:readln("Enter email: ");

                if(emailIn.contains("@")){
                    email = emailIn;
                    run2 = false;
                } else {
                    io:println("Invalid emaid id");
                    continue;
                }
            }
            var op = setStudentDetailsInGSheet("A"+string.convert(row_num+1), "D"+string.convert(row_num+1), name, subject, m, email);

        } else if(operation == 4){
            var noti = sendNotification();
        } else {
            io:println("Invalid choice");
        }
    }
}

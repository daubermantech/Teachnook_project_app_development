Project Overview:
This Flutter project is a task management app with user authentication. Users can log in with a username and password, and once authenticated, they can manage their tasks. The app supports features like creating tasks with titles, descriptions, due dates, labels, priority levels, and reminders. Users can also mark tasks as completed and edit existing tasks.

Now, let's break down the project structure and key components:


1. main.dart:
This is the entry point of the Flutter app.
It initializes the app and sets up the LoginApp widget as the home screen.
The debugShowCheckedModeBanner property is set to false to hide the debug banner in the app.

2. LoginApp (StatelessWidget):
This is the starting point of the app.
It contains the MaterialApp widget, which provides the basic app structure.
The debugShowCheckedModeBanner property is set to false here as well.
The home screen of the app is set to LoginPage.

3. LoginPage (StatefulWidget):
This is the login page of the app.
It allows users to enter their username and password.
Users can tap the "Login" button to initiate the login process.
Successful login redirects users to the TaskListPage.
Users can also toggle between light and dark themes using the theme switcher button in the app bar.

4. _LoginPageState (State class of LoginPage):
Manages the state of the LoginPage.
Contains controllers for username and password input fields.
Handles the login logic (authentication) when the user taps the "Login" button.
Initializes the app's theme, allowing users to switch between light and dark themes.

5. TaskListPage (StatefulWidget):
This is the main task management page.
Displays a list of tasks that belong to the logged-in user.
Users can add new tasks, edit existing tasks, and mark tasks as completed.
Tasks are organized with titles, descriptions, labels, due dates, reminders, and priority levels.
Users can also filter tasks by title using the search bar.

6. _TaskListPageState (State class of TaskListPage):
Manages the state of the TaskListPage.
Loads and saves tasks using shared preferences based on the logged-in user.
Allows users to create new tasks, edit existing tasks, and filter tasks by title.
Handles theme preferences and allows users to switch between light and dark themes.
Implements the logic for scheduling task reminders.

7. Task (Custom Class):
Represents a task in the app.
Contains properties such as id, title, description, completion status, due date, reminder time, labels, and priority.
Used to store and manage task data.
Key Concepts and Features:

User Authentication: Users can log in with a username (no password validation implemented for simplicity).
Theme Preferences: Users can toggle between light and dark themes.
Task Management: Users can create, edit, and complete tasks with various details.
Task Reminders: Users can set reminders for their tasks.
Task Filtering: Users can search for tasks by title.
Data Persistence: Tasks are stored using shared preferences, making them persistent across app sessions.
Overall, this Flutter project serves as a basic task management app with user authentication and theme customization, allowing users to organize and track their tasks effectively. You can further enhance this app by adding more features and refining the user interface.

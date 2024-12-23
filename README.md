# BillBuddy

BillBuddy is an app that allows users to keep track of shared expenses within a group. This application enables users to create groups, add expenses, calculate individual balances, and view a summary of shared expenses.

### Key Features

- **Group Management**: Users can create groups, add participants, and assign a name to the group.
- **Expense Tracking**: Users can add individual expenses for the group, assigning participants and amounts. Each expense can be split among all members or just selected ones.
- **Balances**: The app automatically calculates how much each participant owes or is owed to balance the group's expenses.
- **Photo Album**: Users can add photos for each group, displayed in a grid. (Not yet perfectly implemented)
- **Accessible User Interface**: The app allows users to navigate easily, with accessibility support.

### Main Views

1. **AddGroupView**: Screen for adding a new group and participants. The first participant is automatically identified as "me."
2. **GroupDetailView**: Screen showing the details of a group, including tabs to view expenses, balances, and photos.
3. **ExpensesView**: Screen for viewing all group expenses, adding new expenses, and removing existing ones.
4. **BalancesView**: Screen showing each participant's balance, indicating how much they owe or are owed.
5. **PhotosView**: Screen allowing users to add photos to the group's albums.

### Models

- **Group**: Represents a group of participants, with information such as the group's name and associated expenses.
- **Expense**: Represents an expense, with details like the amount, name, participants, and payer.
- **GroupsModel**: Model managing the logic to add, edit, and remove groups and expenses.

# Lecarda
Learn English by swiping the cards.

1. The app tries to fetch the data from the SQLite database using the Core Data framework.
2. If the database isn't empty, it populates the array and generates 50 random words and phrases, choosing from more than 5000 words and phrases.
3. If it's empty, it checks whether there's an internet connection by using the Network framework.
4. If there's an internet connection, it tries to fetch the data from the Firebase Firestore, saves data to the SQLite database, then populates the array and generates 50 random words and phrases.
5. It shows error messages in certain circumstances.
6. It allows you to learn English words and phrases by swiping the cards.
7. Tap on the card to see the translation.
8. Tap and hold on to the card to hear the pronunciation, it uses the AVFoundation framework.
9. After completing the 50 words and phrases, you will have two options: 
 - Get the same 50 cards again to strengthen the current words and phrases you've just learned.
 - Get 50 new cards to learn new words and phrases.
10. Test your knowledge by choosing the correct translation of the English word or phrase from the 3 options. Each section contains 10 questions.
11. You have 5 seconds to choose the correct answer.
12. Sign in with Apple to save your scores, see the score table and compete with other users.
11. Get notifications daily by activating the daily reminder, it uses the User Notifications framework.

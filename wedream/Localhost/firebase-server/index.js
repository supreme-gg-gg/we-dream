const admin = require("firebase-admin");

const serviceAccount = require("wedream-123-firebase-adminsdk-sbo7g-2e8f5b95f2.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://wedream-123.firebaseio.com",
});

const db = admin.firestore();

async function getAndSortPlayers() {
  const playersRef = db.collection("users");
  const snapshot = await playersRef.orderBy("weekly_xp", "desc").get();

  if (snapshot.empty) {
    console.log("No matching documents.");
    return;
  }

  let players = [];
  snapshot.forEach((doc) => {
    const data = doc.data();
    const profileInfo = data.profile_info || {}; // Handle missing or null profile_info field
    players.push({
      id: doc.id,
      name: profileInfo.name || "", // Get player name from profile_info, handle null or missing name
      xp: data.weekly_xp || 0, // Handle null or missing weekly_xp field
    });
    // players.push({ id: doc.id, ...doc.data() });
  });

  return players;
}

getAndSortPlayers().then((players) => {
  console.log(players);
});

const express = require("express");
const app = express();
const port = 3000;

app.get("/leaderboard", async (req, res) => {
  try {
    const players = await getAndSortPlayers();
    res.json(players);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

// a Firebase Cloud Function run every Sunday at midnight to clear the weekly XP of all users, using a batch write to update all users in a single transaction.
exports.clearWeeklyXP = functions.pubsub
  .schedule("every sunday 00:00")
  .onRun(async (context) => {
    const playersRef = db.collection("users");
    const snapshot = await playersRef.get();
    const batch = db.batch();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return;
    }

    snapshot.forEach(async (doc) => {
      const userRef = playersRef.doc(doc.id);
      batch.update(userRef, {
        "profile_info.xp": 0,
        weekly_xp: 0,
      });
    });

    await batch.commit();
    console.log("Weekly XP cleared for all users.");

    return null;
  });

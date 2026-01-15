const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.autoClearQueueAtMidnight = functions.pubsub
  .schedule("0 0 * * *") // ทุกวัน 00:00
  .timeZone("Asia/Bangkok")
  .onRun(async () => {
    const db = admin.firestore();

    // 1️⃣ อ่าน settings ก่อน
    const settingRef = db.collection("system_settings").doc("queue_clear");
    const settingSnap = await settingRef.get();

    if (!settingSnap.exists) {
      console.log("❌ queue_clear setting not found");
      return null;
    }

    const data = settingSnap.data();

    if (data.autoEnabled !== true || data.mode !== "auto") {
      console.log("⏸ Auto clear disabled (manual mode)");
      return null;
    }

    // 2️⃣ เริ่มล้างจริง
    console.log("⏰ Auto clear active_bookings started");

    const snapshot = await db.collection("active_bookings").get();
    const batch = db.batch();

    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    console.log("✅ Auto clear active_bookings completed");
    return null;
  });

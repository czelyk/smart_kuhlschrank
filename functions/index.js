const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const userId = user.uid;
  const userRef = db.collection("users").doc(userId);

  try {
    // Toplu yazma (Batch Write) işlemi başlat
    const batch = db.batch();

    // 1. Ana kullanıcı dökümanını oluştur
    batch.set(userRef, {
      email: user.email || "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isPremium: false,
    });

    // 2. 'fridge_status' dökümanı
    const statusRef = userRef.collection("fridge_status").doc("main_status");
    batch.set(statusRef, {
      temperature: 4.0,
      humidity: 50.0,
      last_updated: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. 'platforms' koleksiyonu (10 Tane Raf)
    const platformsRef = userRef.collection("platforms");
    for (let i = 1; i <= 10; i++) {
      const platformId = `platform${i}`;
      const newPlatformRef = platformsRef.doc(platformId);
      
      batch.set(newPlatformRef, {
        name: `Shelf ${i}`,
        current_weight_kg: 0.0,
        status: i <= 2 ? "active" : "inactive",
        last_updated: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // 4. 'shopping_list' örneği
    const shoppingListRef = userRef.collection("shopping_list").doc();
    batch.set(shoppingListRef, {
      item_name: "Milk",
      quantity: 1,
      is_bought: false,
      added_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Hepsini tek seferde kaydet
    await batch.commit();

    console.log(`User profile created for ${userId}`);
    return null;

  } catch (error) {
    console.error("Error creating user profile:", error);
    return null;
  }
});

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Función que se activa cuando se crea un nuevo horario en Firestore
exports.sendPushNotification = functions.firestore
  .document("schedules/{scheduleId}") // Ruta al documento de horarios
  .onCreate(async (snap, context) => {
    const newSchedule = snap.data(); // Obtener los datos del horario creado
    const userId = newSchedule.userID; // Obtener el ID del usuario asociado

    try {
      // Obtener el token FCM del usuario desde Firestore
      const userSnapshot = await admin.firestore().collection("users").doc(userId).get();
      const userData = userSnapshot.data();

      if (!userData || !userData.fcm_token) {
        console.log("No se encontró el token FCM para el usuario");
        return;
      }

      const fcmToken = userData.fcm_token; // Token FCM del usuario

      // Preparar el mensaje de la notificación
      const message = {
        notification: {
          title: "¡Hora de alimentar a tu mascota!",
          body: `Es hora de la comida para tu mascota. ${newSchedule.label}`,
        },
        token: fcmToken, // Enviar la notificación al dispositivo con el token
      };

      // Enviar la notificación
      await admin.messaging().send(message);
      console.log("Notificación enviada exitosamente");
    } catch (error) {
      console.error("Error al enviar la notificación:", error);
    }
  });

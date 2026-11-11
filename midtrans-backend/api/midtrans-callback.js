const { getFirestore } = require("../lib/firebase");

module.exports = async (req, res) => {
  // Set CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    console.log("📩 Callback diterima dari Midtrans");
    console.log("Body:", JSON.stringify(req.body, null, 2));

    const firestore = getFirestore();
    const notif = req.body;

    const orderId = notif.order_id;
    const status = notif.transaction_status;
    const fraud = notif.fraud_status;

    if (!orderId || !status) {
      console.error("❌ order_id atau transaction_status tidak ada");
      return res.status(400).json({
        error: "order_id atau transaction_status tidak ada",
      });
    }

    let statusPembayaran = "belum bayar";

    // ======== STATUS SUKSES =========
    if (
      status === "settlement" ||
      (status === "capture" && fraud === "accept")
    ) {
      statusPembayaran = "sudah dp";
      console.log("✅ Status: SUKSES");
    }
    // ======== PENDING ===============
    else if (status === "pending") {
      statusPembayaran = "menunggu pembayaran";
      console.log("⏳ Status: PENDING");
    }
    // ======== GAGAL ==================
    else if (status === "deny" || status === "expire" || status === "cancel") {
      statusPembayaran = "gagal";
      console.log("❌ Status: GAGAL");
    }

    console.log(`🔍 Mencari dokumen dengan bookingId: ${orderId}`);

    const transaksiRef = firestore.collection("transaksi");
    const snap = await transaksiRef.where("bookingId", "==", orderId).get();

    if (snap.empty) {
      console.log("❌ Dokumen tidak ditemukan:", orderId);
      return res.status(404).json({
        message: "Dokumen tidak ditemukan",
        orderId: orderId,
      });
    }

    console.log(`📝 Ditemukan ${snap.size} dokumen`);

    const updatePromises = [];
    snap.forEach((doc) => {
      console.log(`🔄 Updating document: ${doc.id}`);
      updatePromises.push(
        transaksiRef.doc(doc.id).update({
          statusPembayaran: statusPembayaran,
          lastUpdated: new Date().toISOString(),
        })
      );
    });

    await Promise.all(updatePromises);
    console.log("✅ Semua dokumen berhasil diupdate");

    return res.status(200).json({
      success: true,
      message: "Callback berhasil diproses",
      orderId: orderId,
      newStatus: statusPembayaran,
      documentsUpdated: snap.size,
    });
  } catch (err) {
    console.error("🔥 Error di callback:", err);
    return res.status(500).json({
      error: err.message,
      stack: process.env.NODE_ENV === "development" ? err.stack : undefined,
    });
  }
};

const axios = require("axios");

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
    const MIDTRANS_SERVER_KEY = process.env.MIDTRANS_SERVER_KEY;
    const MIDTRANS_BASE_URL =
      "https://app.sandbox.midtrans.com/snap/v1/transactions";

    if (!MIDTRANS_SERVER_KEY) {
      return res.status(500).json({
        status: "error",
        message: "MIDTRANS_SERVER_KEY tidak ditemukan",
      });
    }

    const { order_id, gross_amount } = req.body;

    if (!order_id || !gross_amount) {
      return res.status(400).json({
        status: "error",
        message: "order_id dan gross_amount wajib diisi",
      });
    }

    const parameter = {
      transaction_details: {
        order_id,
        gross_amount: parseInt(gross_amount),
      },
    };

    const response = await axios.post(MIDTRANS_BASE_URL, parameter, {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization:
          "Basic " + Buffer.from(MIDTRANS_SERVER_KEY + ":").toString("base64"),
      },
    });

    return res.status(200).json({
      snap_token: response.data.token,
    });
  } catch (error) {
    console.error("Midtrans Error:", error.response?.data || error.message);
    return res.status(500).json({
      status: "error",
      message: "Gagal membuat transaksi Midtrans.",
      detail: error.response?.data || error.message,
    });
  }
};

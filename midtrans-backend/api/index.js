// api/index.js
module.exports = async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Content-Type", "application/json");

  res.status(200).json({
    status: "ok",
    message: "Midtrans Backend API",
    version: "1.0.0",
    endpoints: {
      root: "/api",
      getSnapToken: "/api/get-snap-token",
      callback: "/api/midtrans-callback",
    },
    timestamp: new Date().toISOString(),
  });
};

module.exports = (req, res) => {
  // HANYA untuk debugging, HAPUS setelah selesai!
  const envCheck = {
    FIREBASE_PROJECT_ID: !!process.env.FIREBASE_PROJECT_ID,
    FIREBASE_PRIVATE_KEY: !!process.env.FIREBASE_PRIVATE_KEY,
    FIREBASE_CLIENT_EMAIL: !!process.env.FIREBASE_CLIENT_EMAIL,
    MIDTRANS_SERVER_KEY: !!process.env.MIDTRANS_SERVER_KEY,
    NODE_ENV: process.env.NODE_ENV,
    VERCEL: process.env.VERCEL,
    VERCEL_ENV: process.env.VERCEL_ENV,
  };

  res.status(200).json(envCheck);
};

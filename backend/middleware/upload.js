// backend/middleware/upload.js
const multer = require('multer');
const multerS3 = require('multer-s3');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const s3 = require('../config/s3');

const BUCKET = process.env.AWS_S3_BUCKET || 'makhzani-uploads';

const imageFilter = (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed (jpg, jpeg, png, webp)'), false);
  }
};

// Avatar storage — merchants and suppliers → s3://bucket/avatars/uuid.ext
const avatarStorage = multerS3({
  s3,
  bucket: BUCKET,
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `avatars/${uuidv4()}${ext}`);
  },
});

// Product image storage → s3://bucket/products/uuid.ext
const productImageStorage = multerS3({
  s3,
  bucket: BUCKET,
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `products/${uuidv4()}${ext}`);
  },
});

const uploadAvatar = multer({
  storage: avatarStorage,
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

const uploadProductImages = multer({
  storage: productImageStorage,
  fileFilter: imageFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB per image
});

// CSV — still disk-based (temp read + delete, never stored long-term)
const { diskStorage } = multer;
const fs = require('fs');

const csvStorage = diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '../uploads/temp');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${uuidv4()}.csv`);
  },
});

const csvFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  if (ext === '.csv') {
    cb(null, true);
  } else {
    cb(new Error('Only CSV files are allowed (.csv)'), false);
  }
};

const uploadCsv = multer({
  storage: csvStorage,
  fileFilter: csvFilter,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
});

module.exports = { uploadAvatar, uploadProductImages, uploadCsv };

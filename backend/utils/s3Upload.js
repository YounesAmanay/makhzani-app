/**
 * S3 Upload Utility
 *
 * Uploads a local file to S3 and returns the public URL.
 * Used by pdfGenerator.js after writing the PDF to a temp path.
 */

const fs = require('fs');
const { Upload } = require('@aws-sdk/lib-storage');
const s3 = require('../config/s3');

const BUCKET = process.env.AWS_S3_BUCKET || 'makhzani-uploads';

/**
 * Upload a local file to S3.
 *
 * @param {string} localPath   - Absolute path to the local file
 * @param {string} s3Key       - S3 object key (e.g. 'pdfs/order-uuid.pdf')
 * @param {string} contentType - MIME type (e.g. 'application/pdf')
 * @returns {Promise<string>}  - Public HTTPS URL of the uploaded file
 */
async function uploadFileToS3(localPath, s3Key, contentType) {
  const fileStream = fs.createReadStream(localPath);

  const upload = new Upload({
    client: s3,
    params: {
      Bucket: BUCKET,
      Key: s3Key,
      Body: fileStream,
      ContentType: contentType,
    },
  });

  await upload.done();

  return `https://${BUCKET}.s3.${process.env.AWS_REGION || 'eu-west-3'}.amazonaws.com/${s3Key}`;
}

module.exports = { uploadFileToS3 };

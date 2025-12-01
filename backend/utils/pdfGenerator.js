const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '../uploads/pdfs');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

/**
 * Generate PDF for a purchase order
 * @param {Object} order - Order object with merchant, supplier, and items
 * @returns {Promise<{filename: string, filepath: string, url: string}>}
 */
async function generateOrderPDF(order) {
  return new Promise((resolve, reject) => {
    try {
      const filename = `order-${order.id}-${Date.now()}.pdf`;
      const filepath = path.join(uploadsDir, filename);

      // Create PDF document
      const doc = new PDFDocument({
        size: 'A4',
        margin: 40,
        bufferPages: true
      });

      // Create write stream
      const stream = fs.createWriteStream(filepath);

      // Pipe the PDF into the file stream
      doc.pipe(stream);

      // Helper functions
      const addSection = (title) => {
        doc.fontSize(12).font('Helvetica-Bold').text(title, { underline: true });
        doc.moveDown(0.3);
      };

      const addField = (label, value) => {
        doc.fontSize(10).font('Helvetica-Bold').text(label, { width: 150, continued: true });
        doc.fontSize(10).font('Helvetica').text(value);
      };

      // Header
      doc.fontSize(24).font('Helvetica-Bold').text('PURCHASE ORDER', { align: 'center' });
      doc.moveDown(0.5);

      // Order info box
      doc.fontSize(10).font('Helvetica');
      const now = new Date();
      const dateStr = `${now.getDate()}/${now.getMonth() + 1}/${now.getFullYear()}`;

      doc.text(`Order #: ${order.order_number || 'N/A'}`);
      doc.text(`Date: ${dateStr}`);
      doc.text(`Status: Draft`);
      doc.moveDown(1);

      // Merchant info
      addSection('FROM (Your Business)');
      doc.fontSize(10).font('Helvetica');
      if (order.merchant) {
        doc.text(order.merchant.name || 'N/A', { fontSize: 11, bold: true });
        if (order.merchant.shop_name) doc.text(`${order.merchant.shop_name}`);
        if (order.merchant.phone_number) doc.text(`Phone: ${order.merchant.phone_number}`);
        if (order.merchant.region) doc.text(`Region: ${order.merchant.region}`);
      }
      doc.moveDown(1);

      // Supplier info
      addSection('TO (Supplier)');
      doc.fontSize(10).font('Helvetica');
      if (order.supplier) {
        doc.text(order.supplier.name || 'N/A', { fontSize: 11, bold: true });
        if (order.supplier.business_name) doc.text(`Business: ${order.supplier.business_name}`);
        if (order.supplier.phone_number) doc.text(`Phone: ${order.supplier.phone_number}`);
        if (order.supplier.email) doc.text(`Email: ${order.supplier.email}`);
        if (order.supplier.address) doc.text(`Address: ${order.supplier.address}`);
      }
      doc.moveDown(1);

      // Items table
      addSection('Items');
      doc.moveDown(0.3);

      // Table headers
      const tableTop = doc.y;
      const col1 = 40;
      const col2 = 250;
      const col3 = 380;
      const col4 = 480;

      doc.fontSize(9).font('Helvetica-Bold');
      doc.text('#', col1, tableTop);
      doc.text('Product', col2, tableTop);
      doc.text('Qty × Unit Price', col3, tableTop);
      doc.text('Total', col4, tableTop);

      // Divider line
      doc.moveTo(40, tableTop + 15).lineTo(540, tableTop + 15).stroke();

      // Table rows
      let itemNumber = 1;
      let currentY = tableTop + 25;
      let grandTotal = 0;

      if (order.items && Array.isArray(order.items)) {
        doc.fontSize(9).font('Helvetica');

        order.items.forEach((item) => {
          const product = item.product || {};
          const quantity = item.quantity || 0;
          const unitPrice = item.unit_price || 0;
          const itemTotal = quantity * unitPrice;
          grandTotal += itemTotal;

          const productName = product.name || 'Unknown Product';
          const unit = product.unit || 'pc';

          // Item number
          doc.text(itemNumber.toString(), col1, currentY);

          // Product name
          doc.text(productName, col2, currentY, { width: 120, ellipsis: true });

          // Quantity and price
          const qtyPrice = `${quantity} ${unit} × ${unitPrice.toFixed(2)} MAD`;
          doc.text(qtyPrice, col3, currentY, { width: 100 });

          // Total
          doc.text(itemTotal.toFixed(2) + ' MAD', col4, currentY);

          currentY += 25;
          itemNumber++;
        });
      }

      // Summary section
      doc.moveTo(40, currentY).lineTo(540, currentY).stroke();
      currentY += 10;

      doc.fontSize(10).font('Helvetica-Bold');
      doc.text('TOTAL AMOUNT:', 380, currentY);
      doc.text(grandTotal.toFixed(2) + ' MAD', 480, currentY, { align: 'left' });

      doc.moveDown(2);

      // Notes section
      if (order.notes) {
        addSection('Notes');
        doc.fontSize(9).font('Helvetica');
        doc.text(order.notes, { width: 500 });
        doc.moveDown(1);
      }

      // Footer
      doc.fontSize(8).font('Helvetica').fillColor('#666666');
      doc.text('This is an auto-generated document by Makhzani Inventory Management System', { align: 'center' });
      doc.text(`Generated on: ${new Date().toLocaleString()}`, { align: 'center' });

      // Finalize PDF
      doc.end();

      // Handle stream events
      stream.on('finish', () => {
        resolve({
          filename: filename,
          filepath: filepath,
          url: `/uploads/pdfs/${filename}`
        });
      });

      stream.on('error', (error) => {
        reject(new Error(`Stream error: ${error.message}`));
      });
    } catch (error) {
      reject(new Error(`PDF generation error: ${error.message}`));
    }
  });
}

module.exports = {
  generateOrderPDF
};

// functions/index.js
// v2 Firestore trigger, explicit handler function to avoid "func is not a function"
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Mailgun = require("mailgun.js");
const formData = require("form-data");

admin.initializeApp();

// define params & secrets
const MAILGUN_API_KEY = defineSecret("MAILGUN_API_KEY");
const MAILGUN_DOMAIN = defineString("MAILGUN_DOMAIN");

const mailgun = new Mailgun(formData);

// helper to render items (same as before)
function renderItemsHtml(items) {
  if (!Array.isArray(items) || items.length === 0) return "<p>No items</p>";
  const rows = items.map((it, idx) => {
    const name = it.name || it.title || `Item ${idx + 1}`;
    const qty = it.quantity ?? 1;
    const price = it.price ?? it.unitPrice ?? 0;
    return `<tr>
      <td style="padding:6px;border:1px solid #eee">${name}</td>
      <td style="padding:6px;border:1px solid #eee;text-align:center">${qty}</td>
      <td style="padding:6px;border:1px solid #eee;text-align:right">₹${price}</td>
    </tr>`;
  }).join("");
  return `<table style="border-collapse:collapse;width:100%;max-width:600px">
    <thead><tr>
      <th style="padding:6px;border:1px solid #eee;text-align:left">Item</th>
      <th style="padding:6px;border:1px solid #eee">Qty</th>
      <th style="padding:6px;border:1px solid #eee;text-align:right">Price</th>
    </tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

// NOTE: define the handler as a named async function (not inline)
async function sendOrderConfirmationHandler(event) {
  try {
    const snap = event.data;
    if (!snap) {
      console.log("No snapshot data; nothing to do.");
      return;
    }

    const order = snap.data();
    const orderRef = snap.ref;
    const orderId = event.params.orderId;

    // Resolve recipient
    const toEmail = order.customerEmail || order.userEmail || order.user_email;
    if (!toEmail) {
      console.log(`Order ${orderId} missing email; skipping.`);
      return;
    }

    // Check paymentConfirmed
    if (order.paymentConfirmed !== true) {
      console.log(`Order ${orderId} paymentConfirmed !== true; skipping.`);
      return;
    }

    // Idempotency: skip if already sent
    const fresh = await orderRef.get();
    const emailState = (fresh.data() && fresh.data().email) || {};
    if (emailState.sent) {
      console.log(`Order ${orderId} already emailed; skipping.`);
      return;
    }

    // Mark sending
    await orderRef.update({
      "email.sending": true,
      "email.sendingAt": admin.firestore.FieldValue.serverTimestamp(),
      "email.attempts": admin.firestore.FieldValue.increment(1)
    });

    // Read secret + param values (safe access)
    const mgApiKey = MAILGUN_API_KEY.value();
    const mgDomain = MAILGUN_DOMAIN.value();

    // Debug log: show presence (not value) so we can confirm secret injection
    console.log("DEBUG: mgDomain=", mgDomain, "mgApiKey_present=", !!mgApiKey, "toEmail=", toEmail);

    if (!mgApiKey || !mgDomain) {
      const errMsg = "Mailgun config missing (api key or domain)";
      console.error(errMsg);
      await orderRef.update({ "email.error": errMsg, "email.sending": false });
      return;
    }

    // create mailgun client
    const mg = mailgun.client({ username: "api", key: mgApiKey });

    const customerName = order.userName || `${order.shippingAddress?.firstName || ""} ${order.shippingAddress?.lastName || ""}`.trim();
    const itemsHtml = renderItemsHtml(order.items || order.cart || []);
    const total = order.totalAmount ?? order.total ?? order.price ?? "N/A";

    const html = `
      <div style="font-family:Arial,Helvetica,sans-serif;line-height:1.4;color:#222">
        <h2>Thank you for your order${customerName ? ", " + customerName : ""}!</h2>
        <p><strong>Order ID:</strong> ${orderId}</p>
        ${itemsHtml}
        <p style="font-size:16px"><strong>Total:</strong> ₹${total}</p>
      </div>
    `;

    const message = {
      from: `Chem Revolutions <orders@${mgDomain}>`,
      to: toEmail,
      subject: `Order Confirmation — ${orderId}`,
      html
    };

    // Log right before send
    console.log("About to call Mailgun API for order", orderId, "to", toEmail);

    // Send
    const response = await mg.messages.create(mgDomain, message);

    console.log("Mailgun response:", response);

    // Mark sent
    await orderRef.update({
      "email.sent": true,
      "email.sentAt": admin.firestore.FieldValue.serverTimestamp(),
      "email.sending": false,
      "email.lastSendResponse": response
    });

    console.log(`Confirmation email sent for order ${orderId} to ${toEmail}`);
    return;
  } catch (err) {
    // Catch-all error handling
    console.error("Handler error:", err);
    try {
      const snap = event.data;
      if (snap && snap.ref) {
        await snap.ref.update({
          "email.error": String(err),
          "email.sending": false,
          "email.lastErrorAt": admin.firestore.FieldValue.serverTimestamp()
        });
      }
    } catch (uerr) {
      console.error("Failed to write error back to Firestore:", uerr);
    }
    // throw to let platform handle retries if appropriate
    throw err;
  }
}

// Export the function using the named handler, and include the secret in options.
// Using explicit named function avoids "func is not a function" edge-cases.
exports.sendOrderConfirmation = onDocumentCreated(
  "orders/{orderId}",
  { secrets: [MAILGUN_API_KEY] },
  sendOrderConfirmationHandler
);

// counter.js - Visitor counter (Azure Function + Cosmos DB)

const API_URL =
  "https://func-cloudresumeapi-dev-weu-hbctdvgfgxe7aucq.westeurope-01.azurewebsites.net/api/visitors";

// Runs when the page has fully loaded
document.addEventListener("DOMContentLoaded", async () => {
  const visitorElement = document.getElementById("visitor-count");

  if (!visitorElement) return;

  // Show loading state
  visitorElement.textContent = "...";

  try {
    // Fetch visitor count from Azure Function API
    const response = await fetch(API_URL);

    // If request failed, throw an error
    if (!response.ok) {
      throw new Error("Request failed with status " + response.status);
    }

    // Convert response to JSON
    const data = await response.json();

    // Display the visitor count
    visitorElement.textContent = Number(data.count).toLocaleString();
  } catch (error) {
    console.error("Visitor counter error:", error);

    // Fallback text if something goes wrong
    visitorElement.textContent = "---";
  }
});
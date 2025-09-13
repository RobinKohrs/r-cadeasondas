document.getElementById("fetchButton").addEventListener("click", () => {
  const resultDiv = document.getElementById("result");
  resultDiv.textContent = "Fetching...";

  // This is the URL of your DEPLOYED R API endpoint on Fly.io
  const apiUrl =
    "https://r-cadeasondas.fly.dev/rating?spotId=584204214e65fad6a7709c58";

  fetch(apiUrl)
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then((data) => {
      // Display the pretty-printed JSON in the result div
      resultDiv.textContent = JSON.stringify(data, null, 2);
    })
    .catch((error) => {
      console.error("Error fetching data:", error);
      resultDiv.textContent =
        "Failed to fetch data. Make sure the R API is running and check the console for errors.";
    });
});

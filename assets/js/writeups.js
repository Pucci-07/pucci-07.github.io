(() => {
  const sequence = ["ArrowUp", "ArrowUp", "ArrowDown", "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowLeft", "ArrowRight", "b", "a"];
  let progress = 0;
  let messageTimer;
  let scanlineTimer;

  document.querySelectorAll(".writeup-card__image img").forEach((image) => {
    image.addEventListener("error", () => {
      image.closest(".writeup-card__image")?.classList.add("has-image-error");
    });
  });

  document.addEventListener("keydown", (event) => {
    const target = event.target;
    if (target instanceof HTMLElement && (target.isContentEditable || ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName))) {
      return;
    }

    const key = event.key.length === 1 ? event.key.toLowerCase() : event.key;
    progress = key === sequence[progress] ? progress + 1 : key === sequence[0] ? 1 : 0;

    if (progress === sequence.length) {
      progress = 0;
      document.querySelector(".cyber-easter-egg")?.remove();
      const message = document.createElement("div");
      message.className = "cyber-easter-egg";
      message.setAttribute("role", "status");
      message.setAttribute("aria-live", "polite");
      message.textContent = "> ACCESS GRANTED // NICE FIND";
      document.body.append(message);
      document.body.classList.add("cyber-scanline");

      window.clearTimeout(messageTimer);
      window.clearTimeout(scanlineTimer);
      messageTimer = window.setTimeout(() => message.remove(), 2600);
      scanlineTimer = window.setTimeout(() => document.body.classList.remove("cyber-scanline"), 2300);
    }
  });
})();

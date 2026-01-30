// speech.js
window.startSpeech = function() {
    if (!('webkitSpeechRecognition' in window)) {
        alert("Reconnaissance vocale non supportée");
        return;
    }

    const recognition = new webkitSpeechRecognition();
    recognition.lang = "fr-FR";  // ou "en-US"
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;

    recognition.onresult = event => {
        const text = event.results[0][0].transcript;
        window.dispatchEvent(new CustomEvent('speechResult', { detail: text }));
    };

    recognition.start();
};

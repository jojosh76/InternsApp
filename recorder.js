// recorder.js
let mediaRecorder;
let audioChunks = [];

window.startVoice = async function() {
    if (!navigator.mediaDevices) {
        alert("Votre navigateur ne supporte pas le micro");
        return;
    }

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    mediaRecorder = new MediaRecorder(stream);

    audioChunks = [];

    mediaRecorder.ondataavailable = event => {
        if (event.data.size > 0) audioChunks.push(event.data);
    };

    mediaRecorder.onstop = () => {
        const blob = new Blob(audioChunks, { type: 'audio/webm' });
        const reader = new FileReader();
        reader.readAsDataURL(blob);
        reader.onloadend = () => {
            const base64data = reader.result;
            window.dispatchEvent(new CustomEvent('voiceMessage', { detail: base64data }));
        };
    };

    mediaRecorder.start();
    console.log("Enregistrement démarré");
};

window.stopVoice = function() {
    if (mediaRecorder) mediaRecorder.stop();
};

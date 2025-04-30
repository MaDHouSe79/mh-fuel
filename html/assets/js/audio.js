var audioPlayer = null;
window.addEventListener('message', function (event) {
    if (event.data.type == "play") {
        if (audioPlayer != null) { audioPlayer.pause(); }
        audioPlayer = new Howl({ src: ["./assets/sounds/" + event.data.file + ".ogg"] });
        audioPlayer.volume(event.data.volume);
        audioPlayer.play();
    } else if (event.data.type == "stop") {
        if (audioPlayer != null) { audioPlayer.stop(); }
    } else if (event.data.type == "pause") {
        if (audioPlayer != null) { audioPlayer.pause(); }
    } else if (event.data.type == "setVolume") {
        if (audioPlayer != null) { audioPlayer.volume(event.data.volume); }
    }
});
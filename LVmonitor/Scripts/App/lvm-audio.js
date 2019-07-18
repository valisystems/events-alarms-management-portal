function PlayPause(id) {
    var a = document.getElementById(id);
    if (a.paused) { a.play(); } else { a.pause(); a.currentTime = 0; }
}
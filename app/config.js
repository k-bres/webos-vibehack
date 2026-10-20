// Launcher configuration. Edit this file, then run webos-launcher/install.sh.
// App ids: run `python3 sync-apps.py --list` (or look in app/apps.js after a sync).
window.CONFIG = {
  // Apps pinned to the dock row at the bottom, in this order. Missing apps are skipped.
  dockApps: ['netflix', 'amazon', 'youtube.leanback.v4', 'hotstar'],

  // Apps never shown as tiles (inputs and Live TV are already in the Inputs menu).
  hiddenApps: [
    'com.gathin.tvhome',
    'com.webos.app.livetv',
    'com.webos.app.hdmi1', 'com.webos.app.hdmi2', 'com.webos.app.hdmi3', 'com.webos.app.hdmi4',
    'com.webos.app.lgchannels',   // LG Channels
    'shortcutcopilot'             // Copilot
  ],

  // HDMI inputs shown as tiles too. icon: 'pc', 'console', 'hdmi' (the default), or an image put
  // next to this file (e.g. 'pc.png'). Add the id to dockApps to pin it to the dock.
  inputTiles: {
    // 'com.webos.app.hdmi1': { title: 'PC', icon: 'pc', color: '#0a84ff' },
    // 'com.webos.app.hdmi2': { title: 'PlayStation', icon: 'console', color: '#003791' }
  },

  // The Live TV app, offered at the end of the Inputs menu. Leave empty to omit.
  liveTvApp: 'com.webos.app.livetv',

  // Tiles per row in the grid; the dock always has this many slots.
  columns: 4
};

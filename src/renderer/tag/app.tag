<app>
    <ika-viewer hide={ !setIksm }></ika-viewer>  
    <session-initializer hide={ setIksm }></session-initializer>

    <script>
    const {ipcRenderer} = require('electron');
    setIksm = false;
    window.tagMessenger = window.tagMessenger || {};
    window.tagMessenger.obs = window.tagMessenger.obs || riot.observable();

    window.tagMessenger.obs.on('oauthGenerateRequested', () => {
        ipcRenderer.send('generateOauth', null);
    });

    window.tagMessenger.obs.on('tokenGenerateRequested', (state) => {
        ipcRenderer.send('generateToken', state.data);
    });

    window.tagMessenger.obs.on('iksmGenerateRequested', (state) => {
        ipcRenderer.send('generateIksm', state.data);
    });

    ipcRenderer.on('oauthGenerated', (event, args) => {
        window.tagMessenger.obs.trigger('oauthGenerated', { data: args });
    });

    ipcRenderer.on('tokenGenerated', (event, args) => {
        window.tagMessenger.obs.trigger('tokenGenerated', { data: args });
    });

    ipcRenderer.on('iksmLoaded', (event, args) => {
        // generate event handle main process, and send loaded event
        setIksm = true;
        this.update();
        window.tagMessenger.obs.trigger('iksmLoaded', { data: args });
    });

    </script>

    <style scoped>
    app {
        display: flex;
        flex-direction: column;
    }

    ika-viewer {
        flex-grow: 1;
    }

    session-initializer {
        flex-grow: 1;
    }
    </style>
</app>

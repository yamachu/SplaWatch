<ika-viewer>
    <webview src="./dummy.html" id="ika-webview" disablewebsecurity partition="persist:ika" autosize="on" />
    <script>

    this.webviewReady = false;
    this.on('mount', () => {
        this.root.querySelector('#ika-webview').addEventListener('dom-ready', function _ready(e) {
            this.webviewReady = true;
            this.root.querySelector('#ika-webview').removeEventListener('dom-ready', _ready);
        }.bind(this));
    });

    this.readyWaiter = undefined;
    function loadSplaWeb(own) {
        clearTimeout(own.readyWaiter);
        own.readyWaiter = setTimeout(() => {
            if (!own.webviewReady)
            {
                loadSplaWeb(own);
                return;
            }
            own.root.querySelector('#ika-webview').loadURL('https://app.splatoon2.nintendo.net/');
        }, 500);
    };

    window.tagMessenger.obs.on('iksmLoaded', (cookie) => {
        console.log('iksm_session', cookie.data);
        loadSplaWeb(this);
    });

    </script>

    <style scoped>
    ika-viewer {
        display: flex;
    }

    #ika-webview {
        flex-grow: 1;
    }
    </style>
</ika-viewer>
<session-initializer>
    <div hide={ hasToken }>
        <p style="word-wrap: break-word;">
            Access: {oauthUrl}
        </p>
        <label>Input account link</label>
        <input type='text' id='selected-link'></input>
        <button click={parseTokenRequest}>Generate token</button>
    </div>

    <script>
    const fs = require('fs');
    const path = require('path');
    
    hasToken = true;
    oauthUrl = "";

    this.on('mount', () => {
        fs.readFile(path.join(process.env.HOME, '.config/SplaWatch/token.json'), (err, data) => {
            if (err) {
                window.tagMessenger.obs.trigger('oauthGenerateRequested');
                hasToken = false;
                this.update();
                return;
            }
            let token = JSON.parse(data)['session_token'];
            notifyTokenGenerated(token);
        });
    });

    window.tagMessenger.obs.on('tokenGenerated', (state) => {
        hasToken = true;
        saveToken(state.data);
        notifyTokenGenerated(state.data);
    });

    window.tagMessenger.obs.on('oauthGenerated', (state) => {
        oauthUrl = state.data;
        this.update();
    })

    parseTokenRequest() {
        let input = this.root.querySelector('#selected-link').value;
        
        let session_token_code = input.match(/&session_token_code=(\S+)&/)[1];
        let sessino_token_code_verifier = input.match(/&state=(\S+)$/)[1];

        window.tagMessenger.obs.trigger('tokenGenerateRequested', {
            data: [ session_token_code, sessino_token_code_verifier ]
        });
    }

    function notifyTokenGenerated(token) {
        window.tagMessenger.obs.trigger('iksmGenerateRequested', {
            data: token
        });
    }

    function saveToken(token) {
        fs.writeFile(path.join(process.env.HOME, '.config/SplaWatch/token.json'),
        JSON.stringify({ session_token: token }), 'utf8',(err) => {
            if (err) {
                console.error(err);
                return;
            }
        });
    }

    </script>
</session-initializer>